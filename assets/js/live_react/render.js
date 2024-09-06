import React from 'react';
import ReactDOMServer from 'react-dom/server';

export function getRender(components) {
  return function render(name, props) {
    const Component = components[name];
    if (!Component) {
      throw new Error(`Component ${name} not found`);
    }

    const html = ReactDOMServer.renderToString(React.createElement(Component, props));

    return {
      html: html,
      head: '',
      css: { code: '', map: '' }
    };
  };
}
