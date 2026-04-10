<?php

namespace AppBundle\Twig;

use eZ\Publish\API\Repository\Repository;
use eZ\Publish\API\Repository\Values\Content\Location;

class ChildrenExtension extends \Twig_Extension
{
    private $repository;

    public function __construct( Repository $repository )
    {
        $this->repository = $repository;
    }

    public function getFunctions()
    {
        return [
            new \Twig_SimpleFunction( 'get_children', [ $this, 'getChildren' ] ),
            new \Twig_SimpleFunction( 'ez_location_children', [ $this, 'getChildren' ] ),
            new \Twig_SimpleFunction( 'get_content_type_identifier', [ $this, 'getContentTypeIdentifier' ] ),
        ];
    }

    /**
     * Returns children of a location as an array of hashes:
     *   [ 'location' => Location, 'content' => Content, 'typeIdentifier' => string ]
     */
    public function getChildren( $location = null, $limit = 100 )
    {
        if ( $location === null || !( $location instanceof Location ) )
        {
            return [];
        }

        try
        {
            $locationService     = $this->repository->getLocationService();
            $contentService      = $this->repository->getContentService();
            $contentTypeService  = $this->repository->getContentTypeService();

            $result   = $locationService->loadLocationChildren( $location, 0, $limit );
            $children = [];

            foreach ( $result->locations as $childLocation )
            {
                $childContent     = $contentService->loadContent( $childLocation->contentInfo->id );
                $childContentType = $contentTypeService->loadContentType( $childLocation->contentInfo->contentTypeId );

                $children[] = [
                    'location'       => $childLocation,
                    'content'        => $childContent,
                    'typeIdentifier' => $childContentType->identifier,
                ];
            }

            return $children;
        }
        catch ( \Exception $e )
        {
            error_log( 'ChildrenExtension::getChildren error: ' . $e->getMessage() );
            return [];
        }
    }

    /**
     * Returns the content type identifier string for a given Content value object.
     */
    public function getContentTypeIdentifier( $content = null )
    {
        if ( $content === null )
        {
            return null;
        }

        try
        {
            $contentTypeService = $this->repository->getContentTypeService();
            $contentType        = $contentTypeService->loadContentType( $content->contentInfo->contentTypeId );
            return $contentType->identifier;
        }
        catch ( \Exception $e )
        {
            error_log( 'ChildrenExtension::getContentTypeIdentifier error: ' . $e->getMessage() );
            return null;
        }
    }

    public function getName()
    {
        return 'app_children_extension';
    }
}
