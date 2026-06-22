function initGallery() : void
{
	const wrapEl = document.querySelector<HTMLElement>('.gallery')!;
	if(!wrapEl) return;

	const stageEl = wrapEl.querySelector<HTMLElement>('.stage')!;

	const slidesEls = stageEl.children;
	if(slidesEls.length === 0) return;

	function toggleGalleryFullscreen() : void
	{
		if(!wrapEl.classList.contains('is-fullscreen')) {
			stageEl.style.scrollBehavior = 'instant';
			wrapEl.classList.add('is-fullscreen');

			document.body.style.overflow = 'hidden';
			stageEl.scrollLeft = stageEl.scrollLeft;
			setTimeout(() => { stageEl.style.scrollBehavior = ''; }, 50);

			history.pushState(null, null, document.URL); // Push empty state whos pop event we can catch to prevent the user from accidentally navigating away in fullscreen by wanting to go back from fullscreen mode.
		}
		else {
			stageEl.style.scrollBehavior = 'instant';
			wrapEl.classList.remove('is-fullscreen');

			document.body.style.overflow = '';
			stageEl.scrollLeft = stageEl.scrollLeft;
			setTimeout(() => { stageEl.style.scrollBehavior = ''; }, 50);

			history.back(); // Clean up the empty state object so navigation works normally again.
		}
	}

	window.addEventListener('popstate', (e) => {
		if(!wrapEl.classList.contains('is-fullscreen')) return;

		history.pushState(null, null, document.URL); // Cooked way to prevent the back button form actually navigating in fullscreen.
		toggleGalleryFullscreen();
	})

	let current = 0;

	// Escape key exits fullscreen
	document.addEventListener('keydown', (e : KeyboardEvent) => {
		switch(e.key) {
			case 'Escape':
				if(wrapEl.classList.contains('is-fullscreen'))
					toggleGalleryFullscreen();
				break;

			case 'ArrowLeft':
				if(wrapEl.classList.contains('is-fullscreen'))
					if(current > 0) goTo(current - 1);
				break;

			case 'ArrowRight':
				if(wrapEl.classList.contains('is-fullscreen'))
					if(current < slidesEls.length - 1) goTo(current + 1);
				break;
		}
	});

	let userInteracted = false;

	wrapEl.querySelector<HTMLElement>('.fullscreen')!
		.addEventListener('click', () => {
			userInteracted = true;
			toggleGalleryFullscreen();
		})

	if(slidesEls.length < 2) return;

	const viewportEl = wrapEl.querySelector<HTMLElement>('.viewport')!;

	const prevButtonEl = wrapEl.querySelector<HTMLElement>('.prev')!;
	const nextButtonEl = wrapEl.querySelector<HTMLElement>('.next')!;
	const navStripEl = wrapEl.querySelector('nav')!;
	const selectionIndicatorEl = navStripEl.querySelector<HTMLElement>('.indicator')!;

	// Arrow navigation
	function updateNavArrows() : void
	{
		prevButtonEl.style.display = current === 0 ? 'none' : '';
		nextButtonEl.style.display = current === slidesEls.length - 1 ? 'none' : '';
	}

	function updateSelectionIndicator() : void
	{
		selectionIndicatorEl.style.transform = `translateX(${current * (2 + 64)}px)`; // 2 px gap between thumbs :ThumbGap
	}

	const storageKey = 'gallery-' + location.pathname;

	let isTriggeredScroll = false;
	function goTo(idx : number) : void
	{
		current = idx;
		isTriggeredScroll = true;
		sessionStorage.setItem(storageKey, String(idx));

		slidesEls[idx].scrollIntoView({behavior: 'smooth', block: 'nearest', inline: 'start'});

		updateSelectionIndicator();
		updateNavArrows();
	}

	prevButtonEl.addEventListener('click', () => {
		userInteracted = true;
		if(current > 0) goTo(current - 1);
	});
	nextButtonEl.addEventListener('click', () => {
		userInteracted = true;
		if(current < slidesEls.length - 1) goTo(current + 1);
	});

	// Navigation interaction
	navStripEl.addEventListener('click', (e: MouseEvent) => {
		let btnEl = e.target as HTMLElement;
		for(let i = 0; btnEl && btnEl.nodeName !== 'BUTTON' && i < 3; i++)
			btnEl = btnEl.parentElement!;
		if(!btnEl || btnEl.nodeName !== 'BUTTON') return;

		userInteracted = true;
		goTo(parseInt(btnEl.dataset.i!, 10));
	});

	// Drag-to-pan
	let dragStartX = 0;
	let mightDrag = false;
	let isDragging = false;

	viewportEl.addEventListener('mousedown', (e : MouseEvent) => {
		e.preventDefault();

		mightDrag = true;
		isDragging = false;
		dragStartX = e.pageX;
		viewportEl.style.cursor = 'grabbing';

		userInteracted = true;
	});

	document.addEventListener('mousemove', (e : MouseEvent) => {
		if(!mightDrag) return;

		if(!isDragging && Math.abs(e.pageX - dragStartX) > 5) {
			isDragging = true;
			stageEl.classList.add('manually-dragging');
		}

		if(isDragging) stageEl.scrollLeft -= e.movementX;
	});

	document.addEventListener('mouseup', (e : MouseEvent) => {
		if(!mightDrag) return;

		mightDrag = false;
		viewportEl.style.cursor = '';

		if(!isDragging) return;

		e.preventDefault(); // prevent turning this into a click.

		stageEl.classList.remove('manually-dragging');

		const idx = Math.round(stageEl.scrollLeft / stageEl.offsetWidth);
		goTo(Math.max(0, Math.min(idx, slidesEls.length - 1)));
	});

	// Horizontal scroll (deltaX) navigates one slide at a time
	stageEl.addEventListener('wheel', (e : WheelEvent) => {
		if(!e.deltaX || Math.abs(e.deltaY) >= Math.abs(e.deltaX)) return;

		userInteracted = true;
	});

	// Update our state after "normal" scroll interaction by the user
	stageEl.addEventListener('scroll', () => {
		if(isTriggeredScroll) { return; }

		userInteracted = true;

		const idx = Math.round(stageEl.scrollLeft / stageEl.offsetWidth);
		if(idx !== current) {
			current = idx;

			updateSelectionIndicator();
			updateNavArrows();
			sessionStorage.setItem(storageKey, String(idx));
		}
	});

	stageEl.addEventListener('scrollend', () => {
		if(isTriggeredScroll) {
			isTriggeredScroll = false;
		}
	});

	// Auto-play: advance every 5s until user interacts
	const autoplay = setInterval(() => {
		if(userInteracted) {
			clearInterval(autoplay);
			return;
		}

		isTriggeredScroll = true;
		goTo((current + 1) % slidesEls.length);
	}, 5000);

	// Restore active index from sessionStorage (scroll-snap resets scrollLeft on reload)
	const saved = sessionStorage.getItem(storageKey);
	if(saved) {
		const idx = parseInt(saved, 10);
		if(idx > 0 && idx < slidesEls.length) {
			current = idx;

			selectionIndicatorEl.style.transition = 'none';
			slidesEls[idx].scrollIntoView({block: 'nearest', inline: 'start', behavior: 'instant'});
			updateSelectionIndicator();
			setTimeout(() => { selectionIndicatorEl.style.transition = ''; }, 100); // have to do this because just toggling the style change will be batched and have no effect.
		}
	}
	updateNavArrows();
}
