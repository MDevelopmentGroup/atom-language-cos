Include (%assert, com.intersystems.XCodeDefines)

Class com.intersystems.Laws.CodexReader Extends %RegisteredObject
{

Property Accumulating As %Boolean [ InitialExpression = 0 ];

Property AccumulatedChars As %String;

Property TitleType As %String(VALUELIST = ",хз,часть,раздел,глава,статья") [ InitialExpression = "хз" ];

Property XmlReader As %XML.TextReader;

/// Garant epub documents contains the Russian criminal law  in the following format (index51.xhtml)
XData Example
{
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>
			Уголовно-процессуальный кодекс РФ
		</title>
		<meta content="http://www.w3.org/1999/xhtml; charset=utf-8" http-equiv="Content-Type"/><link href="stylesheet.css" type="text/css" rel="stylesheet"/>
	</head>
	<body>
<h1 id="sub_4000"><span class="CS">Часть четвертая. Особый порядок уголовного судопроизводства</span></h1>
<p>&#160;</p>
<h1 id="sub_2600"><span class="CS">Раздел XVI. Особенности производства по отдельным категориям уголовных дел</span></h1>
<p>&#160;</p>
<h1 id="sub_11550"><span class="CS">Глава 50. Производство по уголовным делам в отношении несовершеннолетних</span></h1>
<p>&#160;</p>
<h1 id="sub_420" class="AH"><span class="CS">Статья 420.</span> Порядок производства по уголовным делам в отношении несовершеннолетних</h1>
<p id="sub_42001">1. Требования настоящей главы применяются по уголовным делам в отношении лиц, не достигших к моменту совершения преступления возраста восемнадцати лет.</p>
<p id="sub_42002">2. Производство по уголовному делу о преступлении, совершенном несовершеннолетним, осуществляется в общем порядке, установленном <a href="index19.xhtml#sub_20000">частями второй</a> и <a href="index34.xhtml#sub_3000">третьей</a> настоящего Кодекса, с изъятиями, предусмотренными настоящей главой.</p>
<p>&#160;</p>
<h1 id="sub_421" class="AH"><span class="CS">Статья 421.</span> Обстоятельства, подлежащие установлению</h1>
...
</body>
</html>
}

/// starting <h1> node and all its subnodes
Method handleNodeStart()
{
	#dim nodeType As %String = ..XmlReader.NodeType
	#dim nodePath As %String = ..XmlReader.Path
	$$$ASSERT(nodeType="element")

	if $locate(nodePath,"/h1$") {
		Set ..Accumulating=1
		Set ..AccumulatedChars=""
	}
}

/// collect text inside of <h1>...</h1> including all children
Method handleChars()
{
	#dim nodeType As %String = ..XmlReader.NodeType
	#dim nodePath As %String = ..XmlReader.Path
	#dim Value As %String = ..XmlReader.Value
	$$$ASSERT(nodeType="chars")

	if ..Accumulating {
		Set ..AccumulatedChars=(..AccumulatedChars)_" "_(..XmlReader.Value)
		if $locate(nodePath,"/h1/span$") {
			if $locate(Value,"Часть\s") {
				Set ..TitleType="часть"
			} elseif $locate(Value,"Раздел\s") {
				Set ..TitleType="раздел"
			} elseif $locate(Value,"Глава\s") {
				Set ..TitleType="глава"
			} elseif $locate(Value,"Статья\s") {
				Set ..TitleType="статья"
			}
			//&html<TitleType: #(..TitleType)#>
		}
	}
}

/// closing </h1> nodes and all children
Method handleNodeEnd()
{
	#dim nodeType As %String = ..XmlReader.NodeType
	#dim nodePath As %String = ..XmlReader.Path
	$$$ASSERT(nodeType="endelement")

	if $locate(nodePath,"/h1$") {
		Set ..Accumulating=0
		Set ..AccumulatedChars=""
	}
}

Method handleNode()
{
	#dim nodeType As %String = ..XmlReader.NodeType
	#dim nodePath As %String = ..XmlReader.Path

	// open element, e.g. <h1>.
	if nodeType="element" {
		Do ..handleNodeStart()
	}
	// node text, e.g. <h1>blah-blah-blah.
	elseif nodeType="chars" {
		Do ..handleChars()
	}
	// close element, e.g. </h1>
	elseif nodeType="endelement" {
		//&html<#(..XmlReader.Path)# : #(..AccumulatedChars)#>
		Do ..handleNodeEnd()
	}
}

ClassMethod ReadFile(FileName As %String = "C:\Users\Timur\Documents\Intersystems\iknow\garant-laws\data\garant_upk_rf(7)\OEBPS\index51.xhtml", MaxLines As %Integer = -1) As %Status
{
	#dim reader As com.intersystems.XhtmlCodexReader = ##class(com.intersystems.Laws.CodexReader).%New()
	#dim linesCount As %Integer = 0
	#dim xmlReader As %XML.TextReader
	Set Status = ##class(%XML.TextReader).ParseFile(FileName,.xmlReader) Quit:$$$ISERR(Status) 0
	Set reader.XmlReader=xmlReader
	
	// Read all elements within the document
	While (xmlReader.Read()) {
		$$$CheckNumOfLines(linesCount,MaxLines)
		Do reader.handleNode()

		If reader.XmlReader.HasAttributes {
			For J=1:1:reader.XmlReader.AttributeCount {
				$$$CheckNumOfLines(linesCount,MaxLines)

				Do xmlReader.MoveToAttributeIndex(J)
				Do reader.handleNode()
			}
		}
	}
}

}
