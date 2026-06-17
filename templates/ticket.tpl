<?php /** @var array $ticket */

$isModerator = canModerate(null, $user);

?>
{include file="header" hclass="innercontent with-buttons-bottom moderation-request"}

<div style="padding: 1em 1em 0 1em">
	<h2>
		<span>
		<? if($isModerator): ?>
			<a href="/t/">Moderation Requests</a>
		<? else: ?>
			<a href="/t/u/self">My Moderation Requests</a>
		<? endif; ?>
		</span>
		/
		<span><?= $ticket['requestId'] ?></span>
		<span class="tag"><?= $isModerator ? stringify_moderation_request_state($ticket['stateFlags']) : stringify_moderation_request_state_for_user($ticket['stateFlags']) ?></span>
		<? if($isModerator): ?>
		<p class="by-user">By <a href="/show/user/<?= $ticket['initiatorHash'] ?>"><?= escapeHtml($ticket['initiatorName']) ?></a></p>
		<? endif; ?>
	</h2>

	<h3>Request:</h3>
	<div><?= $ticket['request'] /* @security: sanitized on ingest */ ?></div>

	<h3>
		Resolution:
		<? if($isModerator && ($ticket['stateFlags'] & MOD_REQUEST_FLAG_CLOSED)): ?>
		<p class="by-user">By <a href="/show/user/<?= $ticket['resolverHash'] ?>"><?= escapeHtml($ticket['resolverName']) ?></a> (acting moderator only shown to other moderators)</p>
		<? endif; ?>
	</h3>
	<div><?= ($ticket['stateFlags'] & MOD_REQUEST_FLAG_CLOSED) ? $ticket['resolution'] /* @security: sanitized on ingest */ : 'No resolution yet.' ?></div>
</div>

<? if($isModerator && (~$ticket['stateFlags'] & MOD_REQUEST_FLAG_CLOSED)): ?>
<form class="buttons" method="post">
	<h4>You may resolve this request:</h4>
	<div>
		<textarea id="resolve-reason" name="reason" style="width: 100%;"></textarea>
	</div>
	<input type="hidden" name="at" value="<?= $user['actionToken'] ?>">
	<div>
		<button class="button large shine" name="resolution" value="solved">Close as 'Solved'</button>
		<button class="button large shine" name="resolution" value="wontfix">Close as 'Wont Fix'</button>
		<button class="button large btndelete shine" name="resolution" value="spam" style="margin-left:auto;">Dismiss as Spam</button>
	</div>
</form>

<script nonce="<?= $cspNonce ?>">
$(function() { createEditor(R.get('resolve-reason'), tinymceSettingsCmt); });
</script>
<? endif; ?>

{include file="footer"}