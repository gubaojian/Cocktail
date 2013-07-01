/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package cocktail.core.html;
import cocktail.core.css.CascadeManager;
import cocktail.core.css.InitialStyleDeclaration;
import cocktail.core.dom.Document;
import cocktail.core.dom.DOMException;
import cocktail.core.renderer.InitialBlockRenderer;
import cocktail.core.layer.LayerRenderer;
import cocktail.core.parser.ParserData;
import cocktail.core.parser.DOMParser;

/**
 * Root of an HTML document
 * 
 * @author Yannick DOMINGUEZ
 */
class HTMLHtmlElement extends HTMLElement
{	
	/**
	 * class constructor
	 */
	public function new() 
	{
		super(HTMLConstants.HTML_HTML_TAG_NAME);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN GETTER/SETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Overriden to reset the HTMLBodyElement when the innerHTML is set,
	 * as it reset the whole document
	 */
	override private function set_innerHTML(value:String):String
	{
		super.set_innerHTML(value);
		var htmlDocument:HTMLDocument = cast(ownerDocument);
		htmlDocument.initBody(cast(getElementsByTagName(HTMLConstants.HTML_BODY_TAG_NAME)[0]));
		return value;
	}

	/**
	 * Overriden as the HTML element's outerHTML can't be set
	 */
	override private function set_outerHTML(value:String):String
	{
		throw DOMException.NO_MODIFICATION_ALLOWED_ERR;
		return value;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE RENDERING TREE METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * As the ElementRenderer generated by the 
	 * HTMLHTMLElement is the root of the rendering
	 * tree, its parent is always considered rendered
	 * so that this doesn't prevent the rendering of
	 * the document
	 */
	override private function isParentRendered():Bool
	{
		return true;
	}
	
	/**
	 * The HTMLHTMLElement always generate a root rendering
	 * tree element.
	 */
	override private function createElementRenderer():Void
	{ 
		elementRenderer = new InitialBlockRenderer(this, coreStyle);
	}
	
	/**
	 * do nothing as there is no parent ElementRenderern no need to
	 * attach to parent
	 */
	override private function attachToParentElementRenderer():Void
	{
		
	}
	
	/**
	 * As there is no parent ElementRenderer, need to 
	 * detach explicitily the initial block renderer
	 */
	override private function detachFromParentElementRenderer():Void
	{
		elementRenderer.removedFromRenderingTree();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE CASCADING METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * overriden as the HTMLHTMLElement has no HTMLElement parent
	 */
	override private function cascadeSelf(cascadeManager:CascadeManager, programmaticChange:Bool):Void
	{
		if (_needsStyleDeclarationUpdate == true || styleManagerCSSDeclaration == null)
		{
			getStyleDeclaration();
			_needsStyleDeclarationUpdate = false;
		}
		
		if (_shouldCascadeAllProperties == true)
		{
			cascadeManager.shouldCascadeAll();
		}
		else
		{
			var length:Int = _pendingChangedProperties.length;
			for (i in 0...length)
			{
				cascadeManager.addPropertyToCascade(_pendingChangedProperties[i]);
			}
		}
		
		//update the relative reference for the cascade of this node
		//the root html element has special rules as it has no parent
		//It uses the computed font metrics corresponding to the initial values
		//of the font property
		//TODO : implement actual values instead of hard-coded ones
		cascadeManager.parentRelativeLengthReference.em = 12.0;
		cascadeManager.parentRelativeLengthReference.ch = 12.0;
		cascadeManager.parentRelativeLengthReference.ex = 12.0;
		
		//TODO : use the computed value of the initial font-size on the root
		//element instead
		cascadeManager.parentRelativeLengthReference.rem = 12.0;
		
		coreStyle.cascade(cascadeManager, _initialStyleDeclaration, styleManagerCSSDeclaration, style, _initialStyleDeclaration, programmaticChange);
		
		//now that the root element is cascaded, we can retrieve the 'rem' reference which 
		//will be used for all the other nodes in the document
		cascadeManager.parentRelativeLengthReference.rem = coreStyle.fontMetrics.fontSize;
		cascadeManager.relativeLengthReference.rem = coreStyle.fontMetrics.fontSize;
		
		_shouldCascadeAllProperties = false;
		_pendingChangedProperties = [];
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN COORDS GETTERS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Return nothing as the HTMLHTMLElement is the root 
	 * of the rendering tree
	 */
	override private function get_offsetParent():HTMLElement
	{
		return null;
	}
	
	/**
	 * The html root don't have an offset top
	 */
	override private function get_offsetTop():Int
	{
		return 0;
	}
	
	/**
	 * The html root don't have an offset left
	 */
	override private function get_offsetLeft():Int
	{
		return 0;
	}
	
}