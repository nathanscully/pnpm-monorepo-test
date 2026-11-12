import add from 'adder';
"use client"
import React, { useEffect, useRef, useState } from 'react';
import { Simple } from './doms';
export default function Home() {

  const iframeRef = useRef(null);
  const iframeRefBoxes = useRef(null);

  const [simplifedDom, setSimplifiedDom] = useState("");

  function simplifyElement(element: HTMLElement): string {
    switch (element.nodeType) {
      case 1:
        const tagName = element.tagName.toLowerCase();
        let simplifiedStructure = `<${tagName}>`;

        element.childNodes.forEach((child) => {

          simplifiedStructure += simplifyElement(child as HTMLElement);

        });

        simplifiedStructure += `</${tagName}>`;
        return simplifiedStructure;
      case 3:
        return element.textContent || ""
      default:
        return ""
    }

  }


  function logPositions(root: HTMLElement) {
    const boxes = [];
    function traverse(element: HTMLElement, depth: number = 0) {
      element.childNodes.forEach((child) => {
        if (child.hasChildNodes()) {
          boxes.push([child.getBoundingClientRect(), depth]);
          traverse(child as HTMLElement, depth + 1)
        }
        else {
        }
      });
    }
    traverse(root);
    return boxes;
  }

  function simplifyDOM(root: HTMLElement): string[] {
    const simplifiedStructures: string[] = [];

    function traverse(element: HTMLElement) {
      simplifiedStructures.push(simplifyElement(element));
      element.childNodes.forEach((child) => {
        if (child instanceof HTMLElement) {
          traverse(child);
        }
      });
    }

    traverse(root);
    return simplifiedStructures;
  }

  useEffect(() => {
    if (iframeRef.current) {
      const iframeDocument = iframeRef.current.contentDocument || iframeRef.current.contentWindow.document;
      const d = atob(Simple);
      setSimplifiedDom(d)
      iframeDocument.open();
      iframeDocument.write(d);
      iframeDocument.close();
      const s = simplifyDOM(iframeDocument.body);
      const boxes = logPositions(iframeDocument.body);
      const dom = document.implementation.createHTMLDocument();
      for (const [box, depth] of boxes) {
        const e = dom.createElement("div");
        e.style.position = "absolute";
        e.style.top = `${box.top}px`;
        e.style.left = `${box.left}px`;
        e.style.width = `${box.width}px`;
        e.style.height = `${box.height}px`;
        e.style.backgroundColor = "red";
        e.style.border = "1px solid black";
        e.style.opacity = `${(depth + 1) * 0.1}`;
        dom.body.appendChild(e);

      }
      console.log(dom)
      const iframeDocumentBoxes = iframeRefBoxes.current.contentDocument || iframeRefBoxes.current.contentWindow.document;
      iframeDocumentBoxes.open();
      iframeDocumentBoxes.write(dom.documentElement.outerHTML);
      iframeDocumentBoxes.close();
    }
  }, [Simple])

  return (
    <main className="flex min-h-screen flex-row items-center p-24">

      <iframe ref={iframeRef} id="container" width={600} height={800}></iframe>
      <iframe ref={iframeRefBoxes} id="boxes" width={600} height={800}></iframe>

      <div>{simplifedDom}</div>
    </main>
  )
}
