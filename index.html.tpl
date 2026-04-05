<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mi Portfolio - Ángel Moreno</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #f0f2f5;
      color: #333;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .container {
      background: white;
      padding: 50px 60px;
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.08);
      text-align: center;
      max-width: 500px;
      transition: transform 0.3s ease;
    }
    .container:hover {
      transform: translateY(-5px);
    }
    h1 {
      color: #232F3E; /* AWS Navy */
      margin-top: 0;
      font-size: 2.2em;
    }
    h1 span {
      color: #FF9900; /* AWS Orange */
    }
    p {
      font-size: 1.1em;
      line-height: 1.6;
      color: #555;
      margin-bottom: 30px;
    }
    .counter-box {
      margin-top: 20px;
      padding: 25px;
      background: #fafafa;
      border-radius: 12px;
      border: 1px solid #eaeaea;
      transition: box-shadow 0.3s ease;
    }
    .counter-box:hover {
      box-shadow: 0 4px 15px rgba(255, 153, 0, 0.15);
      border-color: #ffe6cc;
    }
    .counter-label {
      font-size: 1rem;
      text-transform: uppercase;
      letter-spacing: 1.5px;
      color: #888;
      font-weight: 600;
    }
    #counter {
      display: block;
      font-size: 3.5em;
      font-weight: 800;
      color: #FF9900;
      margin-top: 5px;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Ángel <span>Moreno</span></h1>
    <p>Este es mi <strong>Cloud Resume Challenge</strong>.<br>Infraestructura desplegada al 100% con Terraform en AWS y CI/CD con GitHub Actions.</p>

    <div class="counter-box">
      <span class="counter-label">Visitas totales</span>
      <span id="counter">...</span>
    </div>
  </div>

  <script>
    async function getVisitorCount() {
      try {
        // Terraform inyectará aquí la URL de tu API
        const response = await fetch("${api_url}");
        
        // Usamos $$ para escapar la variable y que Terraform no se queje
        if (!response.ok) throw new Error(`HTTP $${response.status}`);
        
        const data = await response.json();
        document.getElementById("counter").textContent = data.count;
      } catch (error) {
        document.getElementById("counter").textContent = "Error";
        console.error(error);
      }
    }
    window.onload = getVisitorCount;
  </script>
</body>
</html>
