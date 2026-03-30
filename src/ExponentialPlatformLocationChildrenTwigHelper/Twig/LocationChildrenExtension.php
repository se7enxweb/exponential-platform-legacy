<?php

declare(strict_types=1);

namespace App\ExponentialPlatformLocationChildrenTwigHelper\Twig;

use eZ\Publish\API\Repository\LocationService;
use eZ\Publish\API\Repository\Values\Content\Location;
use eZ\Publish\API\Repository\Values\Content\LocationQuery;
use eZ\Publish\API\Repository\Values\Content\Query\Criterion;
use eZ\Publish\API\Repository\Values\Content\Query\SortClause\ContentName;
use eZ\Publish\API\Repository\Values\Content\Query\SortClause\Location\Priority;
use eZ\Publish\API\Repository\SearchService;
use Twig\Extension\AbstractExtension;
use Twig\TwigFunction;

final class LocationChildrenExtension extends AbstractExtension
{
    private SearchService $searchService;
    private LocationService $locationService;

    public function __construct(SearchService $searchService, LocationService $locationService)
    {
        $this->searchService  = $searchService;
        $this->locationService = $locationService;
    }

    public function getFunctions(): array
    {
        return [
            new TwigFunction('ez_location_children', [$this, 'getChildren']),
        ];
    }

    /**
     * Returns direct child Location objects sorted by priority (asc) then name (asc).
     *
     * @return \eZ\Publish\API\Repository\Values\Content\Location[]
     */
    public function getChildren(Location $location, int $limit = 50): array
    {
        $query = new LocationQuery();
        $query->filter = new Criterion\ParentLocationId($location->id);
        $query->sortClauses = [
            new Priority(),
            new ContentName(),
        ];
        $query->limit = $limit;

        $result = $this->searchService->findLocations($query);

        $locations = [];
        foreach ($result->searchHits as $hit) {
            $locations[] = $hit->valueObject;
        }

        return $locations;
    }
}
