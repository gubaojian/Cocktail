/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktail.domElement.js;
import cocktail.domElement.TextNode;
import cocktail.nativeElement.NativeElement;
import js.Dom;
import js.Lib;
import cocktail.domElement.abstract.AbstractTextDOMElement;

/**
 * This is the JavaScript implementation for the Text DOMElement
 * 
 * @author Yannick DOMINGUEZ
 */
class TextDOMElement extends AbstractTextDOMElement
{
	/**
	 * class constructor
	 */
	public function new(nativeElement:NativeElement = null) 
	{
		super(nativeElement);
	}
	
	
	/**
	 * Append a text node to the current text content.
	 * @param	text a raw string of text
	 */
	override public function appendText(text:TextNode):Void
	{
		super.appendText(text);
		
		if (this._nativeElement != null)
		{
			this._nativeElement.appendChild(text);
		}
		else if (this._parent != null)
		{
			this._parent.nativeElement.appendChild(text);
		}
		else if (this._textDOMElementParent != null)
		{
			if (this._textDOMElementParent.nativeElement != null)
			{
				this._textDOMElementParent.nativeElement.appendChild(text);
			}
			else
			{
				var currentTextDOMElementParent:AbstractTextDOMElement = this._textDOMElementParent;
				var parentNativeElement:NativeElement = null;
				
				while (parentNativeElement == null)
				{
					if (currentTextDOMElementParent.nativeElement != null)
					{
						parentNativeElement = currentTextDOMElementParent.nativeElement;
					}
					else if (currentTextDOMElementParent.parent != null)
					{
						parentNativeElement = currentTextDOMElementParent.parent.nativeElement;
					}
					else
					{
						if (currentTextDOMElementParent.textDOMElementParent != null)
						{
							currentTextDOMElementParent = currentTextDOMElementParent.textDOMElementParent;
						}
						else
						{
							break;
						}
					}
				}
				
				if (parentNativeElement != null)
				{
					parentNativeElement.appendChild(text);
				}
			}
			
		}
		
	}
	
	override public function appendTextDOMElement(textDOMElement:AbstractTextDOMElement):Void
	{
		super.appendTextDOMElement(textDOMElement);
		
		if (this._parent != null)
		{
			this._parent.nativeElement.appendChild(textDOMElement.nativeElement);
		}
		else if (this._textDOMElementParent != null)
		{
			this._textDOMElementParent.appendTextDOMElement(textDOMElement);
		}
		
	}
}