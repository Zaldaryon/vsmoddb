<?php

/** @var array $user */

if(empty($urlparts)) {
	$ids = $con->getCol('SELECT notificationId FROM notifications WHERE !`read` AND userId = ?', [$user['userId']]);
	good($ids);
}

switch($urlparts[0]) {
	case 'all':
		fail(HTTP_NOT_FOUND);

	case 'clear':
		validateMethod('POST');
		$ids = isset($_POST['ids']) && is_string($_POST['ids']) ? explode(',', $_POST['ids']) : ($_POST['ids'] ?? null);
		$ids = forceArrayOfInts($ids, true);
		if(empty($ids)) fail(HTTP_BAD_REQUEST, 'No valid ids provided.');
		
		$foldedIds = implode(',', $ids);

		// @security: Ids ($foldedIds) are knows / filtered to be integers, and therefore sql inert.
		$idsWithoutPermission = $con->getCol("SELECT notificationId FROM notifications WHERE notificationId IN ($foldedIds) AND userId != ?", [$user['userId']]);
		if(!empty($idsWithoutPermission)) fail(HTTP_FORBIDDEN, ['error' => 'Invalid ids provided.', 'invalid_ids' => $idsWithoutPermission]);

		$con->execute("UPDATE notifications SET `read` = 1 WHERE notificationId in ($foldedIds)");
		good();
}
