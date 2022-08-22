import { hellosnapshot1 } from "../../declarations/hellosnapshot1";

document.getElementById("greeting").innerText = "... Please Wait ...";

document.getElementById("historyBuffer").innerText = "... Please Wait ...";

document.getElementById("historyStable").innerText = "... Please Wait ...";

const loadMe = async () => {
  const historyBuffer = await hellosnapshot1.getHistoryBuffer();
  document.getElementById("historyBuffer").innerText = historyBuffer;

  const historyStable = await hellosnapshot1.getHistoryStable();
  document.getElementById("historyStable").innerText = historyStable;
}
loadMe ();

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();

  document.getElementById("greeting").innerText = "... Please Wait ...";
  document.getElementById("historyBuffer").innerText = "... Please Wait ...";
  document.getElementById("historyStable").innerText = "... Please Wait ...";

  // Interact with hellosnapshot1 actor, calling the greet method
  const greeting = await hellosnapshot1.greet(name);

  document.getElementById("greeting").innerText = greeting;

  const historyBuffer = await hellosnapshot1.getHistoryBuffer();
  document.getElementById("historyBuffer").innerText = historyBuffer;

  const historyStable = await hellosnapshot1.getHistoryStable();
  document.getElementById("historyStable").innerText = historyStable;
});
