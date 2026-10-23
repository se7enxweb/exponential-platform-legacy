<?php

namespace AppBundle\EventSubscriber;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\DBAL\Schema\Table;
use EzSystems\DoctrineSchema\API\Event\SchemaBuilderEvent;
use EzSystems\DoctrineSchema\API\Event\SchemaBuilderEvents;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

/**
 * Completes the schema `ezplatform:install` builds with the tables and columns the installed
 * Exponential legacy kernel needs.
 *
 * The installer builds the database from the platform kernel's schema.yaml. That file describes
 * the tables of the 7.5 repository, not the ones the legacy kernel in ezpublish_legacy/ added
 * since: kernel 6.0.15 reads expbookmark_folder and ezcontentbrowsebookmark.folder_id on every
 * admin page, for example, and the legacy pages fail with SQL errors when they are not there.
 *
 * The legacy kernel describes its own schema in share/db_schema.dba (the generic format its
 * installers use for every engine). This subscriber reads that file and adds what schema.yaml
 * lacks: whole tables with their keys and indexes, and on the tables schema.yaml already has, the
 * missing columns and the indexes over them. Nothing schema.yaml defines is changed. The result
 * follows whichever kernel Composer installed (6.0.14 or 6.0.15), and Doctrine writes it for the
 * engine in use (MySQL/MariaDB, PostgreSQL, SQLite).
 */
class LegacyKernelSchemaSubscriber implements EventSubscriberInterface
{
    /** @var string */
    private $schemaFile;

    /**
     * @param string $schemaFile The legacy kernel's share/db_schema.dba
     */
    public function __construct($schemaFile)
    {
        $this->schemaFile = $schemaFile;
    }

    public static function getSubscribedEvents()
    {
        // After the platform kernel's schema.yaml (BuildSchemaSubscriber, priority 200)
        return [
            SchemaBuilderEvents::BUILD_SCHEMA => ['onBuildSchema', 100],
        ];
    }

    public function onBuildSchema(SchemaBuilderEvent $event)
    {
        $definition = $this->loadDefinition();
        $schema = $event->getSchema();
        foreach ($definition as $tableName => $tableDefinition) {
            if ($tableName[0] === '_' || !isset($tableDefinition['fields'])) {
                continue;
            }
            if ($schema->hasTable($tableName)) {
                $this->completeTable($schema->getTable($tableName), $tableDefinition);
            } else {
                $this->createTable($schema, $tableName, $tableDefinition);
            }
        }
    }

    /**
     * @return array table name => generic table definition, empty when there is no legacy kernel
     */
    private function loadDefinition()
    {
        if (!is_readable($this->schemaFile)) {
            return [];
        }
        $schema = null;
        include $this->schemaFile;

        return is_array($schema) ? $schema : [];
    }

    private function createTable(Schema $schema, $tableName, array $tableDefinition)
    {
        $table = $schema->createTable($tableName);
        foreach ($tableDefinition['fields'] as $fieldName => $field) {
            $this->addColumn($table, $fieldName, $field);
        }
        $indexes = isset($tableDefinition['indexes']) ? $tableDefinition['indexes'] : [];
        foreach ($indexes as $indexName => $index) {
            $this->addIndex($table, $indexName, $index);
        }
    }

    private function completeTable(Table $table, array $tableDefinition)
    {
        $added = [];
        foreach ($tableDefinition['fields'] as $fieldName => $field) {
            if (!$table->hasColumn($fieldName)) {
                $this->addColumn($table, $fieldName, $field);
                $added[] = $fieldName;
            }
        }
        if (empty($added) || empty($tableDefinition['indexes'])) {
            return;
        }
        foreach ($tableDefinition['indexes'] as $indexName => $index) {
            $fields = $this->indexFields($index);
            if ($index['type'] !== 'primary' && !$table->hasIndex($indexName) && array_intersect($fields, $added)) {
                $this->addIndex($table, $indexName, $index);
            }
        }
    }

    private function addColumn(Table $table, $name, array $field)
    {
        $length = isset($field['length']) ? $field['length'] : null;
        $options = ['notnull' => !empty($field['not_null'])];
        switch ($field['type']) {
            case 'auto_increment':
                $type = 'integer';
                $options['notnull'] = true;
                $options['autoincrement'] = true;
                break;
            case 'int':
                $type = 'integer';
                break;
            case 'bigint':
                $type = 'bigint';
                break;
            case 'varchar':
            case 'char':
                $type = 'string';
                $options['length'] = $length ?: 255;
                $options['fixed'] = $field['type'] === 'char';
                break;
            case 'float':
            case 'double':
                $type = 'float';
                break;
            case 'decimal':
                $type = 'decimal';
                list($precision, $scale) = array_pad(explode(',', (string) $length), 2, 0);
                $options['precision'] = (int) $precision ?: 10;
                $options['scale'] = (int) $scale;
                break;
            default:
                // longtext, mediumtext, text: MySQL gives these columns no default
                $type = 'text';
                $field['default'] = null;
        }
        if (isset($field['default']) && $field['default'] !== false) {
            $options['default'] = $field['default'];
        }
        $table->addColumn($name, $type, $options);
    }

    private function addIndex(Table $table, $name, array $index)
    {
        $fields = $this->indexFields($index);
        switch ($index['type']) {
            case 'primary':
                $table->setPrimaryKey($fields);
                break;
            case 'unique':
                $table->addUniqueIndex($fields, $name);
                break;
            default:
                $table->addIndex($fields, $name);
        }
    }

    /**
     * @return string[] the column names of an index (an entry can be a name or ['name' => ...])
     */
    private function indexFields(array $index)
    {
        $fields = [];
        foreach ($index['fields'] as $field) {
            $fields[] = is_array($field) ? $field['name'] : $field;
        }

        return $fields;
    }
}
