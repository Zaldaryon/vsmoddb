function attachReportModHandlers()
{
	const buttonEl = R.get('report-mod-btn')!;

	const dialogEl = R.get('report-mod-mdl') as HTMLDialogElement;
	const errContainerEl = dialogEl.getElementsByClassName('err-container')[0];
	const categoryNoteEl = dialogEl.getElementsByClassName('category-note')[0];

	dialogEl.querySelector('[name="category"]')!.addEventListener('change', (e) => {
		switch((e.target as HTMLSelectElement).value) {
			case '9':
				categoryNoteEl.innerHTML = 'This category will not be immediately investigated by moderators, but is instead used to enable users to hide such mods as per their <a href="/accountsettings#gen-ai" target="_blank">configured tolerance</a>.';
				break;
		}
	});

	attachDialogSendHandler(dialogEl, (form, data) => {
		errContainerEl.innerHTML = '&nbsp;';

		if(!data.get('category')) {
			R.markAsErrorElement(form.querySelector('[name="category"]')!);
			return false;
		}

		const reason = data.get('reason') as string | null;
		if(reason) {
			reason.trim();
			data.set('reason', reason);
		}

		if(!reason || reason.length < 100) {
			R.markAsErrorElement(form.getElementsByClassName('tox-tinymce')[0] as HTMLElement);
			errContainerEl.textContent = 'Please provide substantial reasoning for your report.';
			return false;
		}

		return true;
	}, (jqXHR) => {
		R.attachDefaultFailHandler(jqXHR, "Failed to report mod", (err) => {
			if(jqXHR.status == 429) // Too many requests. Special case where we don't escape.
				errContainerEl.innerHTML = err;
			else
				errContainerEl.textContent = err;
			return true;
		})
		.done(() => {
			const link = jqXHR.getResponseHeader('Location')!;
			R.addMessage(MSG_CLASS_OK, `Your report has been submitted (<a href="${link}" target="_blank">link</a>).`, false)
			dialogEl.close();
			(dialogEl.getElementsByClassName('btn-submit')[0] as HTMLButtonElement).disabled = false;
		});
	});

	buttonEl.addEventListener('click', () => {
		const ta = dialogEl.getElementsByTagName('textarea')[0];
		if(ta.style.display !== 'none') createEditor(ta, tinymceSettingsReport);

		dialogEl.showModal();
	})
}
