/* global self, fetch */

import css from "../css/index.styl";

const $profileUrl = document.querySelector(".profile-url");
const $select = document.querySelector(".type-select");
const $submit = document.querySelector(".submit");
const $url = document.querySelector(".submit-url");
const $form = document.querySelector(".form");

// Utility

function toggleClass(el, cl, s) {
  el.classList[s ? "add" : "remove"](cl);
}

function keyCode(e) {
  return e.keyCode || e.which || e.charCode || 0;
}

// Center select element

const ctx = setupCanvasCtx();

function setupCanvasCtx() {
  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");
  ctx.font = "normal 18px sans-sarif";

  return ctx;
}

function getTextWidth(text) {
  return ctx.measureText(text).width;
}

function centerSelect() {
  if (typeof InstallTrigger !== "undefined") return; // skip FireFox
  const optionsText = $select[$select.selectedIndex].text;
  const emptySpace = $select.offsetWidth - getTextWidth(optionsText);

  $select.style["padding-left"] = `${emptySpace / 2}px`;
}

// Show feed url

function extractUserId(profileUrl) {
  const uId = profileUrl
    .trim()
    .toLowerCase()
    .split("soundcloud.com/")[1];

  const isValid =
    uId && !uId.includes("#") && !uId.includes("?") && !uId.includes("/");

  return isValid ? uId : false;
}

async function lookupUserId() {
  const userId = extractUserId($profileUrl.value);
  if (!userId) return shakeForm();

  try {
    showSpinner();
    const response = await fetch(`/lookup/${userId}`);
    const { user_id } = await response.json();
    return user_id;
  } catch (err) {
    shakeForm();
  } finally {
    showSpinner(false);
  }
}

function shakeForm() {
  $profileUrl.focus();
  toggleClass($form, "shake", true);
  setTimeout(() => toggleClass($form, "shake", false), 250);
}

function showSpinner(state = true) {
  toggleClass($submit, "loading", state);
}

function extendBtn(state = true) {
  toggleClass($submit, "full", state);
}

async function onBtnPress({ target: { className } }) {
  if (!["close", "submit-btn"].includes(className)) return;
  if (className === "close") return extendBtn(false);

  const userId = await lookupUserId();
  if (!userId) return;

  const type = $select.value.toLowerCase();
  const url = `${window.location}feeds/${userId}/${type}.rss`;
  $url.setAttribute("href", url);
  $url.innerHTML = url;
  extendBtn();
}

function onEnter(e) {
  if (keyCode(e) !== 13) return;

  e.preventDefault();

  if (!$submit.classList.contains("full")) {
    onBtnPress({ target: { className: "submit-btn" } });
  }
}

function onEsc(e) {
  if (keyCode(e) === 27) extendBtn(false);
}

centerSelect();

$profileUrl.addEventListener("keypress", onEnter);
$select.addEventListener("change", centerSelect);
window.addEventListener("resize", centerSelect);
$submit.addEventListener("click", onBtnPress);
window.addEventListener("keydown", onEsc);

if (!self.fetch) window.alert("Please upgrade your browser!");
