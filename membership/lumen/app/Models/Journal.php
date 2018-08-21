<?php
namespace App\Models;

use Makeradmin\Models\Entity;

/**
 *
 */
class Journal extends Entity
{
	protected $type = "journal";
	protected $table = "membership_journal";
	protected $id_column = "id";
	protected $columns = [
		"id" => [
			"column" => "membership_journal.id",
			"select" => "membership_journal.id",
		],
		"member_id" => [
			"column" => "membership_journal.member_id",
			"select" => "membership_journal.member_id",
		],
		"created_at" => [
			"column" => "membership_journal.created_at",
			"select" => "DATE_FORMAT(membership_journal.created_at, '%Y-%m-%dT%H:%i:%sZ')",
		],
		"event_id" => [
			"column" => "membership_journal.event_id",
			"select" => "membership_journal.event_id",
		],
	];
	protected $sort = ["expires", "desc"];
	protected $validation = [
		"renewed" => ["required"],
		"expires" => ["required"],
	];

	protected function _list($filters = [])
	{
		// Preprocessing (join or type and sorting)
		$this->_preprocessFilters($filters);

		// Build base query
		$query = $this->_buildLoadQuery($filters);

		// Go through filters
		foreach($filters as $id => $filter)
		{
			if(is_array($filter) && count($filter) >= 2)
			{
				$op    = $filter[0];
				$param = $filter[1];
			}
			else
			{
				$op    = "=";
				$param = $filter;
			}

			// Filter on group membership
			if($id == "membership_member")
			{
				$query = $query
					->leftJoin("membership_members_groups", "membership_members_groups.member_id", "=", "membership_members.member_id")
					->where("membership_members_groups.group_id", $op, $param);
				unset($filters[$id]);
			}
		}

		// Apply standard filters like entity_id, relations, etc
		$query = $this->_applyFilter($query, $filters);

		// Sort
		$query = $this->_applySorting($query);

		// Paginate
		if($this->pagination != null)
		{
			$query->paginate($this->pagination);
		}

		// Run the MySQL query
		$data = $query->get();

		// Prepare array to be returned
		$result = [
			"data" => $data
		];

		// Pagination
		if($this->pagination != null)
		{
			$result["total"]     = $query->getCountForPagination();
			$result["per_page"]  = $this->pagination;
			$result["last_page"] = ceil($result["total"] / $result["per_page"]);
		}

		return $result;
	}
}
