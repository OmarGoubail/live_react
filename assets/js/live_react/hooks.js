import React from "react";
import ReactDOM from "react-dom/client";
import ReactDOMServer from "react-dom/server";

function getAttributeJson(el, attributeName) {
  const data = el.getAttribute(attributeName);
  return data ? JSON.parse(data) : {};
}

function getProps(hook) {
  return {
    ...getAttributeJson(hook.el, "data-props"),
    pushEvent: hook.pushEvent.bind(hook),
    pushEventTo: hook.pushEventTo.bind(hook),
    handleEvent: hook.handleEvent.bind(hook),
    upload: hook.upload.bind(hook),
    uploadTo: hook.uploadTo.bind(hook),
  };
}

export function getHooks(components) {
  const ReactHook = {
    _render() {
      const props = getProps(this);
      if (this._root) {
        this._root.render(React.createElement(this._Component, props));
      } else {
        // For SSR, we need to hydrate instead of creating a new root
        ReactDOM.hydrateRoot(this.el, React.createElement(this._Component, props));
      }
    },
    mounted() {
      const componentName = this.el.getAttribute("data-name");
      if (!componentName) {
        throw new Error("Component name must be provided");
      }

      this._Component = components[componentName];
      const isSSR = this.el.getAttribute("data-ssr") === "true";

      if (isSSR) {
        // For SSR, we hydrate the existing content
        this._render();
      } else {
        // For client-side rendering, we create a new root
        this._root = ReactDOM.createRoot(this.el);
        this._render();
      }
    },
    updated() {
      this._render();
    },
    destroyed() {
      if (this._root) {
        window.addEventListener(
          "phx:page-loading-stop",
          () => this._root.unmount(),
          { once: true }
        );
      }
    },
  };

  return { ReactHook };
}

