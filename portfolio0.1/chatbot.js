const API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

const chatContainer = document.querySelector('.chat-container');
const chatToggle = document.getElementById('chatToggle');
const closeBtn = document.getElementById('closeBtn');
const chatMessages = document.getElementById('chatMessages');
const userInput = document.getElementById('userInput');
const sendBtn = document.getElementById('sendBtn');

chatToggle.addEventListener('click', () => {
  chatContainer.classList.add('active');
  chatToggle.style.display = 'none';
});

closeBtn.addEventListener('click', () => {
  chatContainer.classList.remove('active');
  chatToggle.style.display = 'block';
});

sendBtn.addEventListener('click', sendMessage);
userInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') sendMessage();
});

function addMessage(text, isUser) {
  const messageDiv = document.createElement('div');
  messageDiv.className = `message ${isUser ? 'user-message' : 'bot-message'}`;
  messageDiv.textContent = text;
  chatMessages.appendChild(messageDiv);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

function showTyping() {
  const typingDiv = document.createElement('div');
  typingDiv.className = 'typing';
  typingDiv.textContent = 'Typing...';
  typingDiv.id = 'typing';
  chatMessages.appendChild(typingDiv);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

function removeTyping() {
  const typing = document.getElementById('typing');
  if (typing) typing.remove();
}

async function sendMessage() {
  const message = userInput.value.trim();
  if (!message) return;

  addMessage(message, true);
  userInput.value = '';
  showTyping();

  try {
    const response = await fetch(`${API_URL}?key=${AIzaSyDnmd8L1pAbzEBvjVuoU2yem2B4sPiKvgI}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: message }]
        }]
      })
    });

    const data = await response.json();
    removeTyping();

    if (data.candidates && data.candidates[0] && data.candidates[0].content) {
      const botResponse = data.candidates[0].content.parts[0].text;
      addMessage(botResponse, false);
    } else if (data.error) {
      addMessage(`Error: ${data.error.message}`, false);
    } else {
      addMessage('Sorry, I could not process your request.', false);
    }
  } catch (error) {
    removeTyping();
    addMessage(`Error: ${error.message}`, false);
  }
}

// Initial greeting
addMessage('Hello! How can I help you today?', false);
