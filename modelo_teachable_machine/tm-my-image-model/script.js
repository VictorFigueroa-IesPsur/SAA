// Cargar el modelo al iniciar la página
async function init() {
  const modelURL = "model.json";
  const metadataURL = "metadata.json";
  model = await tmImage.load(modelURL, metadataURL);
  maxPredictions = model.getTotalClasses();
  console.log("Modelo cargado correctamente");
}

init();

const imageInput = document.getElementById("image-input");
const predictBtn = document.getElementById("predict-btn");
const predList = document.getElementById("pred-list");
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

imageInput.addEventListener("change", () => {
  if (!imageInput.files || !imageInput.files[0]) return;

  const img = new Image();
  img.src = URL.createObjectURL(imageInput.files[0]);

  img.onload = () => {
    // Limpiar el canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Calcular escala para centrar la imagen sin distorsionarla
    const scale = Math.min(canvas.width / img.width, canvas.height / img.height);
    const x = (canvas.width / 2) - (img.width / 2) * scale;
    const y = (canvas.height / 2) - (img.height / 2) * scale;

    // Dibujar imagen centrada
    ctx.drawImage(img, x, y, img.width * scale, img.height * scale);
  };
});

predictBtn.addEventListener("click", async () => {
  if (!imageInput.files || !imageInput.files[0]) {
    alert("Por favor, selecciona una imagen primero.");
    return;
  }

  // Cargar la imagen seleccionada
  const img = new Image();
  img.src = URL.createObjectURL(imageInput.files[0]);

  img.onload = async () => {
    // Dibujar en el canvas (necesario para pasarla al modelo)
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
    const prediction = await model.predict(canvas);
    showResults(prediction);
  };
});

function showResults(predictions) {
  predList.innerHTML = "";
  predictions.sort((a, b) => b.probability - a.probability);

  predictions.forEach(p => {
    const li = document.createElement("li");
    li.textContent = `${p.className}: ${(p.probability * 100).toFixed(2)}%`;
    predList.appendChild(li);
  });
}