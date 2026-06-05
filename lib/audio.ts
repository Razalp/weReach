export function playAlarmSound(durationMs: number = 2000) {
    const AudioContextConstructor =
        window.AudioContext ||
        (window as Window & { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;

    if (!AudioContextConstructor) return;

    const ctx = new AudioContextConstructor();
    let oscillator: OscillatorNode | null = null;
    let gainNode: GainNode | null = null;
    let isPlaying = true;

    const playBeep = () => {
        if (!isPlaying || ctx.state === 'closed') return;

        oscillator = ctx.createOscillator();
        gainNode = ctx.createGain();

        oscillator.type = "square";
        oscillator.frequency.setValueAtTime(880, ctx.currentTime); // A5
        oscillator.frequency.exponentialRampToValueAtTime(440, ctx.currentTime + 0.1);

        gainNode.gain.setValueAtTime(0.3, ctx.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.1);

        oscillator.connect(gainNode);
        gainNode.connect(ctx.destination);

        oscillator.start();
        oscillator.stop(ctx.currentTime + 0.1);

        // Schedule next beep
        setTimeout(playBeep, 200); // Faster beeps for preview/alert
    };

    playBeep();

    // Stop after duration
    setTimeout(() => {
        isPlaying = false;
        if (ctx.state !== 'closed') ctx.close();
    }, durationMs);
}
