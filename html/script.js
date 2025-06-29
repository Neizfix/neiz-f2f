let countdownInterval;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'startCountdown') {
        startCountdown(data.number);
    } else if (data.type === 'stopCountdown') {
        stopCountdown();
    }
});

function startCountdown(startNumber) {
    const container = document.getElementById('countdown-container');
    const numberElement = document.getElementById('countdown-number');
    
    // UI'yi göster
    container.classList.remove('hidden');
    container.classList.add('fade-in');
    
    let currentNumber = startNumber;
    numberElement.textContent = currentNumber;
    
    countdownInterval = setInterval(() => {
        currentNumber--;
        
        if (currentNumber > 0) {
            numberElement.textContent = currentNumber;
            numberElement.style.animation = 'none';
            setTimeout(() => {
                numberElement.style.animation = 'numberPulse 0.5s ease-in-out';
            }, 10);
        } else {
            // Geri sayım bitti
            numberElement.textContent = 'BAŞLA!';
            numberElement.style.color = '#00ff00';
            numberElement.style.textShadow = '0 0 20px #00ff004d, 0 0 40px #00ff004d';
            
            setTimeout(() => {
                stopCountdown();
            }, 1000);
        }
    }, 1000);
}

function stopCountdown() {
    const container = document.getElementById('countdown-container');
    
    clearInterval(countdownInterval);
    
    // UI'yi gizle
    container.classList.add('fade-out');
    
    setTimeout(() => {
        container.classList.add('hidden');
        container.classList.remove('fade-in', 'fade-out');
        
        // NUI'yi kapat
        fetch(`https://${GetParentResourceName()}/countdownFinished`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }, 300);
} 