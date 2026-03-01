import React, { useState } from 'react';
import { ClipboardCopy, CheckCircle, AlertTriangle } from 'lucide-react';

const CuestionarioCAP = () => {
  const [formData, setFormData] = useState({
    nombre: '',
    cargo: '',
    turno: '',
    experiencia: ''
  });

  const [responses, setResponses] = useState({});
  const [copyStatus, setCopyStatus] = useState(null); // 'success', 'error', null
  const [validationError, setValidationError] = useState(false);

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setValidationError(false);
  };

  const handleRadioChange = (questionId, value) => {
    setResponses({ ...responses, [questionId]: parseInt(value) });
    setValidationError(false);
  };

  const calculateScores = () => {
    // Inversión de puntajes para patología de inmovilidad
    const reverseScore = (val) => 6 - val;

    // Sección I: Conocimientos (Max 25) - Q1 a Q4 invertidas para medir déficit
    const sec1 = 
      (responses[1] ? reverseScore(responses[1]) : 0) +
      (responses[2] ? reverseScore(responses[2]) : 0) +
      (responses[3] ? reverseScore(responses[3]) : 0) +
      (responses[4] ? reverseScore(responses[4]) : 0) +
      (responses[5] || 0);

    // Sección II: Actitudes (Max 20) - Mide barreras cognitivas (directo)
    const sec2 = (responses[6] || 0) + (responses[7] || 0) + (responses[8] || 0) + (responses[9] || 0);

    // Sección III: Prácticas (Max 20) - Mide institucionalización de la inmovilidad. Q11 invertida.
    const sec3 = 
      (responses[10] || 0) + 
      (responses[11] ? reverseScore(responses[11]) : 0) + 
      (responses[12] || 0) + 
      (responses[13] || 0);

    return { sec1, sec2, sec3 };
  };

  const generateReport = () => {
    const scores = calculateScores();
    const date = new Date().toLocaleDateString('es-VE', {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit'
    });

    let report = `=== REPORTE CAP: INASS NAGUANAGUA ===\n`;
    report += `Fecha y Hora: ${date}\n\n`;
    report += `[DATOS DEL CUIDADOR]\n`;
    report += `Nombre: ${formData.nombre}\n`;
    report += `Cargo: ${formData.cargo}\n`;
    report += `Turno: ${formData.turno}\n`;
    report += `Experiencia: ${formData.experiencia} años\n\n`;
    
    report += `[PUNTUACIONES BRUTAS (1-5)]\n`;
    for (let i = 1; i <= 13; i++) {
      report += `Ítem ${i}: ${responses[i]}\n`;
    }

    report += `\n[ANÁLISIS DIMENSIONAL - ÍNDICE DE RIESGO]\n`;
    report += `(A mayor puntaje, mayor riesgo de inducir iatrogenia por inmovilidad)\n`;
    report += `Déficit de Conocimiento Fisiopatológico: ${scores.sec1}/25\n`;
    report += `Actitudes y Barreras Cognitivas: ${scores.sec2}/20\n`;
    report += `Prácticas Clínicas Iatrogénicas: ${scores.sec3}/20\n`;
    report += `========================================`;

    return report;
  };

  const copyToClipboard = () => {
    // Validación estricta
    if (!formData.nombre || !formData.cargo || !formData.turno || Object.keys(responses).length < 13) {
      setValidationError(true);
      return;
    }

    const textToCopy = generateReport();
    
    // Método robusto para iFrames (document.execCommand)
    const textArea = document.createElement("textarea");
    textArea.value = textToCopy;
    textArea.style.position = "fixed"; 
    textArea.style.left = "-999999px";
    textArea.style.top = "-999999px";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
      document.execCommand('copy');
      setCopyStatus('success');
      setTimeout(() => setCopyStatus(null), 3000);
    } catch (err) {
      console.error('Error al copiar', err);
      setCopyStatus('error');
    } finally {
      textArea.remove();
    }
  };

  const questions = [
    { id: 1, section: 1, text: "El reposo absoluto en cama es la medida preventiva más eficaz y segura para evitar el deterioro orgánico en el adulto mayor frágil." },
    { id: 2, section: 1, text: "La pérdida severa de fuerza y masa muscular (dinapenia y sarcopenia) es un proceso biológico irreversible en el cual la terapia física no tiene impacto demostrable." },
    { id: 3, section: 1, text: "Una alimentación hiperproteica es suficiente por sí sola para mantener el trofismo muscular del anciano, incluso si este permanece inmovilizado." },
    { id: 4, section: 1, text: "La contracción muscular inducida por ejercicios de resistencia leve en ancianos agrava los procesos inflamatorios sistémicos preexistentes." },
    { id: 5, section: 1, text: "El encamamiento prolongado induce alteraciones cardiovasculares severas, como la pérdida del reflejo barorreceptor (hipotensión ortostática)." },
    { id: 6, section: 2, text: "Considero que fomentar proactivamente la deambulación en residentes inestables expone mi praxis profesional a riesgos legales o sanciones administrativas por riesgo de caídas." },
    { id: 7, section: 2, text: "Percibo que el escenario intrahospitalario ideal y más seguro se logra cuando la mayoría de los pacientes permanecen tranquilos en sus lechos." },
    { id: 8, section: 2, text: "Siento que el esfuerzo físico y logístico requerido para asistir la marcha terapéutica de los residentes genera una sobrecarga laboral que excede mis funciones básicas." },
    { id: 9, section: 2, text: "Me genera elevada ansiedad observar a los pacientes frágiles intentando movilizarse de forma autónoma, prefiriendo ejecutar las tareas de la vida diaria por ellos." },
    { id: 10, section: 3, text: "¿Con qué frecuencia indica o promueve el reposo en cama como primera medida terapéutica ante quejas somáticas inespecíficas (sin signos de alarma) del residente?", isFrequency: true },
    { id: 11, section: 3, text: "¿Con qué frecuencia asiste de manera proactiva la sedestación al borde de la cama o la bipedestación de los pacientes durante su guardia, excluyendo los traslados higiénicos obligatorios?", isFrequency: true },
    { id: 12, section: 3, text: "¿Con qué frecuencia emplea mecanismos de contención física preventiva (barandas elevadas continuas, sujeción) en pacientes con deterioro cognitivo leve-moderado para evitar su deambulación no supervisada?", isFrequency: true },
    { id: 13, section: 3, text: "¿Con qué frecuencia las limitaciones neuroarquitectónicas del INASS (ausencia de pasamanos, iluminación deficiente) son el factor determinante para que usted prohíba la caminata de un residente?", isFrequency: true }
  ];

  return (
    <div className="min-h-screen bg-slate-50 py-8 px-4 sm:px-6 lg:px-8 font-sans text-slate-800">
      <div className="max-w-4xl mx-auto bg-white rounded-xl shadow-md overflow-hidden">
        
        {/* Header Institucional */}
        <div className="bg-slate-800 p-6 text-white border-b-4 border-blue-500">
          <h1 className="text-2xl font-bold uppercase tracking-wide">Evaluación Diagnóstica (FASE PRECEDE)</h1>
          <p className="mt-2 text-slate-300">Cuestionario de Conocimientos, Actitudes y Prácticas (CAP) sobre Movilidad Geriátrica</p>
          <div className="mt-4 inline-flex items-center px-3 py-1 rounded-full bg-blue-500/20 text-blue-200 text-sm font-semibold">
            INASS Naguanagua
          </div>
        </div>

        <div className="p-6 sm:p-8 space-y-8">
          
          {/* Alerta de Validación */}
          {validationError && (
            <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-md flex items-start">
              <AlertTriangle className="text-red-500 w-5 h-5 mr-3 mt-0.5 flex-shrink-0" />
              <div>
                <h3 className="text-red-800 font-medium">Formulario Incompleto</h3>
                <p className="text-red-600 text-sm mt-1">Debe llenar los datos del cuidador y responder los 13 ítems clínicos para generar la tabulación estadística.</p>
              </div>
            </div>
          )}

          {/* Datos Demográficos */}
          <section className="bg-slate-50 p-6 rounded-lg border border-slate-200">
            <h2 className="text-lg font-bold text-slate-800 mb-4 border-b pb-2">Datos del Evaluado</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Nombre o Código</label>
                <input type="text" name="nombre" value={formData.nombre} onChange={handleInputChange} className="w-full rounded-md border-slate-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border" placeholder="Identificador..." />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Cargo / Función</label>
                <select name="cargo" value={formData.cargo} onChange={handleInputChange} className="w-full rounded-md border-slate-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border bg-white">
                  <option value="">Seleccione...</option>
                  <option value="Enfermero/a Titulado">Enfermero/a Titulado</option>
                  <option value="Auxiliar de Enfermería">Auxiliar de Enfermería</option>
                  <option value="Cuidador/a formal">Cuidador/a formal</option>
                  <option value="Otro">Otro</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Turno de Trabajo</label>
                <select name="turno" value={formData.turno} onChange={handleInputChange} className="w-full rounded-md border-slate-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border bg-white">
                  <option value="">Seleccione...</option>
                  <option value="Mañana">Mañana</option>
                  <option value="Tarde">Tarde</option>
                  <option value="Noche">Noche</option>
                  <option value="Rotativo">Rotativo</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Años de Experiencia Geriátrica</label>
                <input type="number" name="experiencia" value={formData.experiencia} onChange={handleInputChange} className="w-full rounded-md border-slate-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 p-2 border" min="0" placeholder="Ej. 5" />
              </div>
            </div>
          </section>

          {/* Cuestionario Clínico */}
          {[1, 2, 3].map(sectionNum => {
            const sectionTitles = {
              1: "I. Dimensión de Conocimientos Fisiopatológicos",
              2: "II. Dimensión de Actitudes y Creencias (Factores Predisponentes)",
              3: "III. Dimensión de Prácticas Clínicas (Factores Reforzadores)"
            };
            
            const isFrequency = sectionNum === 3;
            const labels = isFrequency 
              ? ["Nunca (1)", "Rara vez (2)", "A veces (3)", "Frec. (4)", "Siempre (5)"]
              : ["TD (1)", "ED (2)", "Ind. (3)", "DA (4)", "TA (5)"];

            return (
              <section key={sectionNum} className="space-y-4">
                <h2 className="text-xl font-bold text-slate-800 border-b-2 border-slate-200 pb-2">
                  {sectionTitles[sectionNum]}
                </h2>
                
                <div className="space-y-6">
                  {questions.filter(q => q.section === sectionNum).map((q) => (
                    <div key={q.id} className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm hover:border-blue-300 transition-colors">
                      <p className="text-slate-800 font-medium mb-4"><span className="text-blue-600 font-bold mr-2">{q.id}.</span>{q.text}</p>
                      
                      <div className="grid grid-cols-5 gap-2 sm:gap-4">
                        {[1, 2, 3, 4, 5].map((val, idx) => (
                          <label key={val} className={`flex flex-col items-center p-2 rounded cursor-pointer transition-colors ${responses[q.id] === val ? 'bg-blue-50 ring-2 ring-blue-500' : 'bg-slate-50 hover:bg-slate-100'}`}>
                            <input
                              type="radio"
                              name={`q${q.id}`}
                              value={val}
                              checked={responses[q.id] === val}
                              onChange={(e) => handleRadioChange(q.id, e.target.value)}
                              className="w-4 h-4 text-blue-600 border-slate-300 focus:ring-blue-500 mb-2"
                            />
                            <span className="text-xs sm:text-sm font-medium text-slate-600 text-center">{labels[idx]}</span>
                          </label>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            );
          })}

          {/* Action Footer */}
          <div className="pt-6 border-t border-slate-200 sticky bottom-0 bg-white/95 backdrop-blur-sm p-4 rounded-b-xl shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)]">
            <button
              onClick={copyToClipboard}
              className="w-full flex items-center justify-center py-4 px-6 border border-transparent rounded-lg shadow-sm text-lg font-bold text-white bg-slate-800 hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-slate-500 transition-all"
            >
              <ClipboardCopy className="w-6 h-6 mr-2" />
              Procesar y Copiar Resultados al Portapapeles
            </button>
            
            {copyStatus === 'success' && (
              <div className="mt-4 flex items-center justify-center text-emerald-600 bg-emerald-50 p-3 rounded-md">
                <CheckCircle className="w-5 h-5 mr-2" />
                <span className="font-medium">Tabulación copiada al portapapeles exitosamente. Lista para pegar.</span>
              </div>
            )}
          </div>

        </div>
      </div>
    </div>
  );
};

export default CuestionarioCAP;
