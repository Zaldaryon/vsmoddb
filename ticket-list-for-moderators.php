<?php
/** @var object $con */
/** @var object $view */
/** @var array $config */
/** @var array<string> $urlparts */

if(empty($user['userId']))   showErrorPage(HTTP_UNAUTHORIZED);
if(!canModerate(null, $user))   showErrorPage(HTTP_FORBIDDEN);

require($config['basepath'].'lib/moderation.php');


$modReports = $con->getAll("
	SELECT requestId, kind, category, referenceId,
		IF(LENGTH(requestSearchable) > 256, CONCAT(SUBSTR(requestSearchable, 1, 256), '...'), requestSearchable) AS requestSearchable
	FROM moderationRequests
	WHERE kind = ".MOD_REQUEST_KIND_REPORT_MOD." AND category != ".REPORT_CATEGORY_MOD_LOW_EFFORT_AI." AND (~stateFlags & ".MOD_REQUEST_FLAG_CLOSED.") 
	ORDER BY referenceId, created DESC
");

$reportedModIds = array_unique(array_column($modReports, 'referenceId'), SORT_NUMERIC);
$foldedModIds = implode(',', $reportedModIds);

$reportedMods = $reportedModIds ? $con->getAssoc(<<<SQL
	SELECT m.modId, a.assetId, m.urlAlias, a.name, m.summary, f.cdnPath AS logoCdnPath
	FROM mods m
	JOIN assets a ON a.assetId = m.assetId
	LEFT JOIN files f ON f.fileId = m.cardLogoFileId
	WHERE m.modId IN ($foldedModIds)
SQL) : [];

foreach($modReports as $report) {
	$reportedMods[$report['referenceId']]['reports'][] = $report;
}

usort($reportedMods, fn($a, $b) => -(count($a['reports']) <=> count($b['reports']))); // sort by report count descending


$view->assign('pagetitle', 'Open Moderation Requests - ');
$view->assign('reportedMods', $reportedMods, null, true);
$view->display('ticket-list-for-moderators');
