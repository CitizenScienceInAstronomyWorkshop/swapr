
Public.Ajax = class Ajax

  @base_url : "http://localhost:4567/"

  @cors_options: (url, data, type)->
    dataType: 'json'
    type: type
    url : @full_url(url)
    data: data
    xhrFields:
      withCredentials: true
    crossDomain: true


  @full_url: (url)->
    "#{@base_url}#{url}"

  @get : (url,data={})->
    $.ajax @cors_options(url, data, "GET")

  @post: (url,data={})->
    $.ajax @cors_options(url, data, "POST")
