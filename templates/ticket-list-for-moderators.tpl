<?php
/** @var array $reportedMods */
/** @var array $user */
?>{include file="header"}

<h2 style="margin-bottom: .5em;">
	<span>Open Moderation Requests</span>
</h2>

<div>
	<h3 style="margin-bottom: .5em;">Reported Mods:</h3>
	<div id="reported-mods">
	<? foreach($reportedMods as $mod): ?>
		<div>
			<a href="<?= formatModPath($mod) ?>">
				<img src="<?= empty($mod['logoCdnPath']) ? '/web/img/mod-default.png' : escapeHtml(formatCdnUrlFromCdnPath($mod['logoCdnPath'])) ?>" alt="Mod Thumbnail" loading="lazy" />
				<div>
					<h3><?= escapeHtml($mod['name']) ?></h3>
					<p><?= escapeHtml($mod['summary']) ?></p>
				</div>
			</a>
			<div class="ticket-list">
			<? foreach($mod['reports'] as $ticket): ?>
				<a href="/t/<?= $ticket['requestId'] ?>">
					<h4><?= stringifyModerationRequestKind($ticket) ?></h4>
					<div><?= $ticket['requestSearchable'] ?></div>
				</a>
			<? endforeach; ?>
			</div>
		</div>
	<? endforeach; if(empty($reportedMods)): ?>
		<div>
			<div>
				<div>
					<h3>Nothing here.</h3>
					<p>No reports here.</p>
				</div>
			</div>
		</div>
	<? endif; ?>
	</div>
</div>

{include file="footer"}