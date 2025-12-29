// Share Feature Configuration
const url = "snailsim.crap.games";

const remarks = [
    "Check out my snail trail on " + url,
    "Snail mail from " + url,
    "Follow my slime trail on " + url,
    "Snail art at " + url,
    "My snail's trail on " + url,
    "Slime tracks at " + url,
    "Snail life on " + url,
    "I'm a trailblazing snail on " + url,
    "My gastropod art on " + url,
    "Snail safari at " + url,
    "Follow my snail trail on " + url,
    "Snail ya later at " + url,
    "If your foot was your stomach, you'd be at " + url,
    "Get slimy with me at " + url,
    "It's a snail of a trail at " + url,
    "My snail moves at the speed of awesome on " + url,
    "This slime is my masterpiece on " + url,
    "Snail power activated on " + url,
    "I left a trail of glory on " + url,
    "Snailtastic adventures await at " + url,
    "My shell is coming off on " + url,
    "This snail is on fire on " + url,
    "I'm not slow, I'm snail-y on " + url,
    "Snail mail delivery service at " + url,
    "My snail senses are tingling on " + url,
    "This gastropod is groovy on " + url,
    "Snail velocity maximum on " + url,
    "I've got snail game on " + url,
    "Shell yeah! Check it out at " + url,
    "My snail game is strong on " + url,
    "This trail is lit on " + url,
    "Snail mode engaged on " + url,
    "I'm feeling snail-tastic on " + url,
    "My snail fu is unmatched on " + url,
    "Trail blazing like a boss on " + url,
    "Snail life finds a way on " + url,
    "This gastropod is legendary on " + url,
    "My snail senses are tingling on " + url,
    "Snail power level 9000 on " + url,
    "I've mastered the snail arts on " + url,
    "Shell we go again on " + url,
    "This snail is unstoppable on " + url
];

// Share Feature Functions

// Function to hide UI elements for screenshot
function hideUIForScreenshot() {
    const shareButton = document.getElementById('share-button');
    const musicToggle = document.getElementById('music-toggle');
    
    if (shareButton) shareButton.style.display = 'none';
    if (musicToggle) musicToggle.style.display = 'none';
}

// Function to restore UI elements after screenshot
function restoreUIAfterScreenshot() {
    const shareButton = document.getElementById('share-button');
    const musicToggle = document.getElementById('music-toggle');
    
    if (shareButton) shareButton.style.display = 'flex';
    if (musicToggle) musicToggle.style.display = 'flex';
}

// Function to capture screenshot
async function captureScreenshot() {
    // Hide UI elements temporarily
    hideUIForScreenshot();
    
    // Wait a frame for UI to hide
    await new Promise(resolve => requestAnimationFrame(resolve));
    
    try {
        // Randomly select a creative remark
        const randomRemark = remarks[Math.floor(Math.random() * remarks.length)];
        
        // Capture the canvas
        const canvas = document.getElementById('canvas');
        
        // Check if canvas exists and has content
        if (!canvas) {
            throw new Error('Canvas not found');
        }
        
        // Get canvas context with fallback
        let ctx = null;
        try {
            ctx = canvas.getContext('2d');
        } catch (contextError) {
            console.warn('Could not get canvas context:', contextError);
        }
        
        // Determine content bounds for cropping
        let sourceX = 0, sourceY = 0, sourceWidth = canvas.width, sourceHeight = canvas.height;
        
        if (ctx) {
            try {
                // Get image data for content detection
                const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                const data = imageData.data;
                
                // Find content boundaries
                let minX = canvas.width, minY = canvas.height, maxX = 0, maxY = 0;
                let hasContent = false;
                
                // Sample every 10th pixel for performance
                for (let y = 0; y < canvas.height; y += 10) {
                    for (let x = 0; x < canvas.width; x += 10) {
                        const index = (y * canvas.width + x) * 4;
                        const r = data[index];
                        const g = data[index + 1];
                        const b = data[index + 2];
                        const a = data[index + 3];
                        
                        // Check if pixel is not transparent or black (content)
                        if (a > 0 && (r > 0 || g > 0 || b > 0)) {
                            hasContent = true;
                            minX = Math.min(minX, x);
                            minY = Math.min(minY, y);
                            maxX = Math.max(maxX, x);
                            maxY = Math.max(maxY, y);
                        }
                    }
                }
                
                if (hasContent) {
                    // Add some padding around content
                    const padding = 20;
                    sourceX = Math.max(0, minX - padding);
                    sourceY = Math.max(0, minY - padding);
                    sourceWidth = Math.min(canvas.width - sourceX, maxX - minX + padding * 2);
                    sourceHeight = Math.min(canvas.height - sourceY, maxY - minY + padding * 2);
                    
                    console.log(`Cropping to content area: ${sourceX}, ${sourceY}, ${sourceWidth}x${sourceHeight}`);
                } else {
                    console.log('No content detected, using full canvas');
                }
            } catch (error) {
                console.warn('Content detection failed:', error);
            }
        } else {
            console.log('Using full canvas (no context available)');
        }
        
        // Target size for the final image
        const targetWidth = 800;
        const qrCodePadding = 120; // Space for QR code and text
        const targetHeight = Math.round((sourceHeight / sourceWidth) * targetWidth) + qrCodePadding;
        
        // Create a temporary canvas for the cropped and scaled image with padding
        const tempCanvas = document.createElement('canvas');
        const tempCtx = tempCanvas.getContext('2d');
        tempCanvas.width = targetWidth;
        tempCanvas.height = targetHeight;
        
        // Draw the cropped and scaled game content at the top
        const gameHeight = targetHeight - qrCodePadding;
        tempCtx.drawImage(canvas, 
            sourceX, sourceY, sourceWidth, sourceHeight,  // Source rectangle
            0, 0, targetWidth, gameHeight           // Destination rectangle (top area)
        );
        
        // Fill the padding area with rainbow gradient background (reversed order)
        const gradient = tempCtx.createLinearGradient(0, gameHeight, targetWidth, targetHeight);
        gradient.addColorStop(0, '#8800ff'); // Violet
        gradient.addColorStop(0.17, '#0000ff'); // Indigo
        gradient.addColorStop(0.33, '#0088ff'); // Blue
        gradient.addColorStop(0.5, '#00ff00'); // Green
        gradient.addColorStop(0.67, '#ffff00'); // Yellow
        gradient.addColorStop(0.83, '#ff8800'); // Orange  
        gradient.addColorStop(1, '#ff0000'); // Red
        tempCtx.fillStyle = gradient;
        tempCtx.fillRect(0, gameHeight, targetWidth, qrCodePadding);
        
        // Generate QR code using qrcodejs
        let qrCodeDataUrl = null;
        if (typeof QRCode !== 'undefined') {
            try {
                // Create a temporary div for QR code generation
                const tempDiv = document.createElement('div');
                tempDiv.style.position = 'absolute';
                tempDiv.style.left = '-9999px';
                document.body.appendChild(tempDiv);
                
                // Generate QR code with appropriate size for padding area
                const qrSize = 80; // Fixed smaller size for QR code
                new QRCode(tempDiv, {
                    text: 'https://all.crap.games',
                    width: qrSize,
                    height: qrSize,
                    colorDark: '#000000',
                    colorLight: '#FFFFFF',
                    correctLevel: QRCode.CorrectLevel.H
                });
                
                // Wait for QR code to be generated and get the image
                await new Promise(resolve => setTimeout(resolve, 100));
                const qrImage = tempDiv.querySelector('img');
                if (qrImage) {
                    qrCodeDataUrl = qrImage.src;
                }
                
                // Clean up
                document.body.removeChild(tempDiv);
                
                // Add overlays to the scaled image
                if (qrCodeDataUrl) {
                    const qrImg = new Image();
                    qrImg.onload = function() {
                        // Add URL text on the left side of padding area
                        const fontSize = Math.round(targetWidth * 0.025); // Scale font with image
                        const urlY = gameHeight + qrCodePadding / 2;
                        tempCtx.fillStyle = 'black';
                        tempCtx.font = `bold ${fontSize}px Arial`;
                        tempCtx.fillText(randomRemark, 30, urlY + fontSize / 3);
                        
                        // Add QR code with white background on the right side
                        const qrX = targetWidth - qrSize - 20; // Right side with margin
                        const qrY = gameHeight + (qrCodePadding - qrSize) / 2; // Center in padding area
                        
                        tempCtx.fillStyle = 'white';
                        tempCtx.fillRect(qrX - 3, qrY - 3, qrSize + 6, qrSize + 6);
                        tempCtx.drawImage(qrImg, qrX, qrY, qrSize, qrSize);
                        
                        // Convert to blob and share
                        tempCanvas.toBlob(async function(blob) {
                            restoreUIAfterScreenshot();
                            await shareScreenshot(blob, 'snail-trail.png');
                        }, 'image/png');
                    };
                    qrImg.src = qrCodeDataUrl;
                } else {
                    // Fallback without QR code
                    addTextOverlaysAndShare();
                }
            } catch (qrError) {
                console.error('QR Code generation error:', qrError);
                addTextOverlaysAndShare();
            }
        } else {
            console.warn('QRCode library not loaded');
            addTextOverlaysAndShare();
        }
        
        function addTextOverlaysAndShare() {
            // Add URL text on the left side as fallback
            const fontSize = Math.round(targetWidth * 0.025);
            const urlY = gameHeight + qrCodePadding / 2;
            tempCtx.fillStyle = 'black';
            tempCtx.font = `bold ${fontSize}px Arial`;
            tempCtx.fillText(randomRemark, 30, urlY + fontSize / 3);
            
            tempCanvas.toBlob(async function(blob) {
                restoreUIAfterScreenshot();
                await shareScreenshot(blob, 'snail-trail.png');
            }, 'image/png');
        }
        
    } catch (error) {
        console.error('Error capturing screenshot:', error);
        restoreUIAfterScreenshot();
    }
}

// Function to share screenshot using Web Share API or download
async function shareScreenshot(blob, filename) {
    const file = new File([blob], filename, { type: 'image/png' });
    
    // Check if Web Share API is supported
    if (navigator.share && navigator.canShare && navigator.canShare({ files: [file] })) {
        try {
            const randomShareRemark = remarks[Math.floor(Math.random() * remarks.length)];

            await navigator.share({
                title: 'Check out my snail trail!',
                text: randomShareRemark,
                files: [file],
                url: window.location.href
            });
            console.log('Screenshot shared successfully');
        } catch (error) {
            if (error.name !== 'AbortError') {
                console.log('Share cancelled or failed, falling back to download');
                downloadScreenshot(blob, filename);
            }
        }
    } else {
        // Fallback: Download the image
        downloadScreenshot(blob, filename);
    }
}

// Function to download screenshot
function downloadScreenshot(blob, filename) {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    console.log('Screenshot downloaded');
}

// Initialize share feature when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    const shareButton = document.getElementById('share-button');
    if (shareButton) {
        shareButton.addEventListener('click', captureScreenshot);
        console.log('Share feature initialized');
    } else {
        console.warn('Share button not found');
    }
});
