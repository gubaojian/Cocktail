/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktailCore.resource.abstract;
import cocktail.domElement.DOMElement;
import cocktail.nativeElement.NativeElement;
import cocktail.nativeElement.NativeElementManager;
import cocktail.nativeElement.NativeElementData;
import cocktailCore.resource.ResourceLoader;
import haxe.Http;
import haxe.Log;

/**
 * This class is in charge of loading one picture
 * 
 * @author Yannick DOMINGUEZ
 */
class AbstractImageLoader extends ResourceLoader
{
	/**
	 * A reference to the native element actually loading
	 * the asset. For instance in Flash, a Loader, in JS,
	 * an img tag. when multiple picture are loaded, no
	 * new NativeElement are created, the picture of the
	 * NativeElement is only replaced
	 */
	private var _nativeElement:NativeElement;
	public var nativeElement(getNativeElement, never):NativeElement;
	
	/**
	 * class constructor
	 */
	public function new(nativeElement:NativeElement = null)
	{
		//create an image nativeElement if none is provided and store
		//it
		if (nativeElement == null)
		{
			nativeElement = NativeElementManager.createNativeElement(image);
		}
		_nativeElement = nativeElement;
		super();
	}
	
	private function getNativeElement():NativeElement
	{
		return _nativeElement;
	}
}