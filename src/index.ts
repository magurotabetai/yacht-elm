import './index.css';
// @ts-ignore
import { Elm } from './Main.elm';

const rootEl = document.querySelector('#root');
if (rootEl) {
  Elm.Main.init({
    node: rootEl,
  });
}
