import { GoogleGenerativeAI } from "https://esm.run/@google/generative-ai";

// ⚠️ COLOQUE SUA API KEY AQUI (Não deixe a real no código final se puder evitar)
const API_KEY = "AIzaSyBsM0lNCjy_Yx4bY-Vnzhd3y9tbVgt-9Lc";

const genAI = new GoogleGenerativeAI(API_KEY);
const modelGemini = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

// ==========================================
// VARIÁVEIS GLOBAIS
// ==========================================
let modelCoco = null;
let video = document.getElementById("video");
let canvas = document.getElementById("canvas");
let ctx = canvas.getContext("2d");
let isGeminiThinking = false;

const startBtn = document.getElementById("start-btn");
const geminiBtn = document.getElementById("gemini-btn");
const statusIndicator = document.getElementById("status");
const initialScreen = document.getElementById("initial-screen");
const cameraScreen = document.getElementById("camera-screen");

// ==========================================
// FUNÇÃO DE FALA (GLOBAL)
// ==========================================
function speak(text) {
  window.speechSynthesis.cancel();
  // Limpeza do texto para não falar caracteres estranhos
  const cleanText = text
    .replace(/#/g, "")
    .replace(/\*/g, "")
    .replace(/`/g, "")
    .replace(/\n/g, ". ");

  const utterance = new SpeechSynthesisUtterance(cleanText);
  utterance.lang = "pt-BR";
  window.speechSynthesis.speak(utterance);
}

// ==========================================
// NOVO: SISTEMA DE BOTÕES FALANTES 🔊
// ==========================================
// Pega todos os botões da tela
const todosBotoes = document.querySelectorAll("button");

todosBotoes.forEach((botao) => {
  // Quando clicar no botão (antes de executar a ação), ele fala o que é
  botao.addEventListener("click", () => {
    const textoBotao = botao.getAttribute("data-som");
    if (textoBotao) speak(textoBotao);
  });
});

// ==========================================
// AÇÃO 1: INICIAR SISTEMA
// ==========================================
startBtn.addEventListener("click", async () => {
  // Pequeno delay para dar tempo de ouvir o nome do botão
  setTimeout(async () => {
    initialScreen.style.display = "none";
    cameraScreen.style.display = "block";
    geminiBtn.style.display = "block";

    speak("Iniciando câmera...");
    await startCamera();

    modelCoco = await cocoSsd.load();
    statusIndicator.innerText = "✅ Modo Radar Ativo";

    startRealTimeDetection();
    speak(
      "Sistema pronto. Aponte a câmera e toque no botão laranja para descrever."
    );
  }, 1000);
});

// ==========================================
// FUNÇÃO: Câmera
// ==========================================
async function startCamera() {
  const stream = await navigator.mediaDevices.getUserMedia({
    video: { facingMode: "environment" },
  });
  video.srcObject = stream;
  return new Promise(
    (resolve) =>
      (video.onloadedmetadata = () => {
        video.play();
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        resolve();
      })
  );
}

// ==========================================
// FUNÇÃO: Radar (Coco-SSD)
// ==========================================
function startRealTimeDetection() {
  setInterval(async () => {
    if (modelCoco && !isGeminiThinking) {
      const predictions = await modelCoco.detect(video);
      // Aqui você pode adicionar lógica para avisar obstáculos próximos
    }
  }, 500);
}

// ==========================================
// AÇÃO 2: GEMINI (DESCRIÇÃO)
// ==========================================
geminiBtn.addEventListener("click", async () => {
  if (isGeminiThinking) return;

  isGeminiThinking = true;
  geminiBtn.innerText = "⏳ Analisando...";
  speak("Analisando imagem..."); // Feedback sonoro imediato

  try {
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    const base64Image = canvas.toDataURL("image/jpeg").split(",")[1];

    const prompt =
      "Descreva esta cena para uma pessoa cega. Seja breve. Responda em português.";

    const result = await modelGemini.generateContent([
      prompt,
      { inlineData: { data: base64Image, mimeType: "image/jpeg" } },
    ]);

    const response = await result.response;
    const text = response.text();

    console.log(text);
    speak(text);
  } catch (error) {
    console.error(error);
    speak("Erro ao conectar.");
  } finally {
    isGeminiThinking = false;
    geminiBtn.innerText = "👁️ O que tem na minha frente?";
  }
});
