window.addEventListener('message', (event) => {
    if (event.data.type === 'playSound') {
        const sound = document.getElementById('gavelSound');
        sound.volume = event.data.volume || 1.0;
        sound.play();
    }
});
