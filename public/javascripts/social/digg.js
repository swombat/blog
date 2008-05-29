
(function(){var ds=typeof digg_skin=='string'?digg_skin:'';var h=80;var w=52;if(ds=='compact'){h=18;w=120;}
else if(ds=='icon'){h=16;w=16;}
var u=typeof digg_url=='string'?digg_url:(typeof DIGG_URL=='string'?DIGG_URL:window.location.href);document.write("<iframe src='http://digg.com/tools/diggthis.php?u="+
escape(u).replace(/\+/g,'%2b')+
(typeof digg_title=='string'?('&t='+escape(digg_title)):'')+
(typeof digg_window=='string'?('&w='+escape(digg_window)):'')+
(typeof digg_bodytext=='string'?('&b='+escape(digg_bodytext)):'')+
(typeof digg_media=='string'?('&m='+escape(digg_media)):'')+
(typeof digg_topic=='string'?('&c='+escape(digg_topic)):'')+
(typeof digg_bgcolor=='string'?('&k='+escape(digg_bgcolor)):'')+
(ds?('&s='+ds):'')+"' height='"+h+"' width='"+w+"' frameborder='0' scrolling='no'></iframe>");})()