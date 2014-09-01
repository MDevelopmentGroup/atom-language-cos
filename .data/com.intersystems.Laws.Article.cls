Class com.intersystems.Laws.Article Extends %Persistent [ StorageStrategy = "" ]
{

/// Часть %
Property PartN As %String(MAXLEN = 120);

/// Раздел %
Property DivisionN As %String(MAXLEN = 120);

/// Глава %
Property ChapterN As %String(MAXLEN = 120);

/// собственно текст статьи
Property Text As %String;

<Storage name="Default">
<Data name="ArticleDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PartN</Value>
</Value>
<Value name="3">
<Value>DivisionN</Value>
</Value>
<Value name="4">
<Value>ChapterN</Value>
</Value>
<Value name="5">
<Value>Text</Value>
</Value>
</Data>
<DataLocation>^com.intersystems.Laws.ArticleD</DataLocation>
<DefaultData>ArticleDefaultData</DefaultData>
<IdLocation>^com.intersystems.Laws.ArticleD</IdLocation>
<IndexLocation>^com.intersystems.Laws.ArticleI</IndexLocation>
<StreamLocation>^com.intersystems.Laws.ArticleS</StreamLocation>
<Type>%Library.CacheStorage</Type>
</Storage>
}
