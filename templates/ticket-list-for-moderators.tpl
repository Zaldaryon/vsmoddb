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
					<h3><?= stringifyModerationRequestKind($ticket) ?></h3>
					<div><?= $ticket['requestSearchable'] ?></div>
				</a>
			<? endforeach; if(empty($mod['reports'])): ?>
				<div>
					<h3>Nothing Here</h3>
					<div>No requests here right now.</div>
				</div>
			<? endif; ?>
			</div>
		</div>
	<? endforeach; ?>
	</div>
</div>

{include file="footer"}