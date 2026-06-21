<?php

// Unfortunately we have to do this in php now, as we need all ids for the php ordering and therefore need to have them returned from the database.
$showDeleted = canModerate(null, $user);


$visibleCommentCount = $showDeleted ? count($comments) : array_reduce($comments, fn($count, $comment) => $count + ($comment['deleted'] ? 0 : 1), 0);

?>

{if isset($user)}
<dialog id="report-cmt-mdl" closedby="any">
	<form class="with-buttons-bottom text-section" method="dialog" data-method="PUT" autocomplete="off" action="{generated}">
		<h1>Report Comment</h1>
		<div style="margin-bottom: 1em;">
			<p>I (<in>{$user['name']}</in>) would like to report this comment (<i id="cmt-ellipsis">Comment Ellipsis</i>) for violating the following rule:</p>
			<select name="category" class="no-chosen" autofocus style="width: 100%;">
				<option value="">-- Please Select --</option>
				<? foreach(REPORT_CATEGORIES_COMMENT as $key => $description): ?>
				<option value="<?= $key ?>"><?= $description ?></option>
				<? endforeach; ?>
			</select>
			<p style="margin-top: .5em;"><i>(see the <a href="/terms" target="_blank">terms of use</a> page for more details on our rules)</i></p>
		</div>
		
		<div style="margin-bottom: 1em;">
			<p>Details on how the rule is being violated:</p>
			<textarea name="reason" style="width: 100%; min-height: 10em;"></textarea>
		</div>
		
		<p><i>This report will be sent to review by moderators.</i></p>

		<div class="err-container">&nbsp;</div>
		
		<input type="hidden" name="at" value="{$user['actionToken']}">
		<div class="buttons">
			<button class="button large btndelete shine btn-submit" onclick="return false;">Report</button>
			<button class="button large shine" style="margin-left:auto;" formmethod="dialog">Cancel</button>
		</div>
	</form>
</dialog>
{/if}

<div style="clear:both;"><br></div>
<h3><a name="comments"></a>{$visibleCommentCount} Comment{$visibleCommentCount !== 1 ? 's' : ''} <span style="font-size:70%">(<a id="cmt-ord-asc" href="#" onclick="return false;">oldest first</a> | <a id="cmt-ord-desc" href="#" onclick="return false;">newest first</a>) (<a id="cmt-threaded" href="#" onclick="return false;">threaded</a> | <a id="cmt-flat" href="#" onclick="return false;">flat</a>)</span></h3>
<div class="comments{if $threaded = ($_COOKIE['commentstructure'] ?? '') !== 'flat'} threaded{/if}">
	{if !empty($user)}
	<div class="comment comment-editor editbox overlay-when-banned overlay-when-readonly" style="display:none;">
		<div class="title">Add new comment:</div>
		<div class="body">
			
			<form name="commentformtemplate" autocomplete="off">
				<textarea name="commenttext" class="whitetext editor" data-editorname="comment" style="width: 100%; height: 50px;"></textarea>
			</form>
		</div>
		<p style="margin:4px; margin-top:5px;"><button class="button shine" type="submit" name="save">Add Comment</button>
	</div>
	{/if}
<?php

	if($threaded) \{
		// :MirroredLayouting
		$depthStack = [];

		foreach($comments as $i => $comment) \{
			for(; count($depthStack) && $depthStack[count($depthStack) - 1] >= $comment['responseDepth']; array_pop($depthStack)) \{
				?></div><?php
			}

			if($comment['children'] > 0) \{
				?><div class="convo"><?php
				array_push($depthStack, $comment['responseDepth']);
			}

			if(!$comment['deleted'] || $showDeleted) \{

				$view->assign('i', $i, null, true);
				$view->assign('comment', $comment, null, true);
				$view->load('comment');
			}
		}

		for($i = 0; $i < count($depthStack); $i++) \{
			?></div><?php
		}
	}
	else \{
		foreach($comments as $i => $comment) \{
			if(!$comment['deleted'] || $showDeleted) \{
				$view->assign('i', $i, null, true);
				$view->assign('comment', $comment, null, true);
				$view->load('comment');
			}
		}
	}
?>
</div>
