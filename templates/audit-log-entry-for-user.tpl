<tr>
<td title="<?= $logEntry['created'] ?>"><?= formatDateRelative($logEntry['created']) ?></td>
<? require($this->templatedir.'audit-log-entry-cell-referenced-asset.tpl'); ?>
<? require($this->templatedir.'audit-log-entry-cells-kind-info.tpl'); ?>
</tr>