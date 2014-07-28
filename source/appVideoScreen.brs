'**********************************************************
'**  Video Player Example Application - Video Playback 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

'***********************************************************
'** Create and show the video screen.  The video screen is
'** a special full screen video playback component.  It 
'** handles most of the keypresses automatically and our
'** job is primarily to make sure it has the correct data 
'** at startup. We will receive event back on progress and
'** error conditions so it's important to monitor these to
'** understand what's going on, especially in the case of errors
'***********************************************************  
Function showVideoScreen(episode As Object)

    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to showVideoScreen"
        return -1
    endif

    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.SetMessagePort(port)

    screen.SetPositionNotificationPeriod(30)
    screen.SetContent(episode)
    screen.Show()

    'Uncomment his line to dump the contents of the episode to be played
    PrintAA(episode)

    while true
        msg = wait(0, port)

        if type(msg) = "roVideoScreenEvent" then
            print "showHomeScreen | msg = "; msg.getMessage() " | index = "; msg.GetIndex()
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            elseif msg.isRequestFailed()
                print "Video request failure: "; msg.GetIndex(); " " msg.GetData() 
            elseif msg.isStatusMessage()
                print "Video status: "; msg.GetIndex(); " " msg.GetData() 
            elseif msg.isButtonPressed()
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            elseif msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                RegWrite(episode.ContentId, nowpos.toStr())
            else
                print "Unexpected event type: "; msg.GetType()
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while

End Function

Function showVideoScreen2(episode As Object)
    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to showVideoScreen"
        return -1
    endif 
    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen") 
    episode.HDBranded = true 
    episode.IsHD = true

    conn = CreateObject("roAssociativeArray")
    ip = GetAuthData()
    conn.UrlPrefix   = "http://"+ip+":9009/"
    conn.UrlCategoryFeed = conn.UrlPrefix + "source.xml"
    http = NewHttp(conn.UrlCategoryFeed)
    Dbg("url: ", http.Http.GetUrl())
    rsp = http.GetToStringWithRetry()
    if rsp=invalid then
      print 'invalid ip'
    else
        
        xml=CreateObject("roXMLElement")

        if not xml.Parse(rsp) then
            print "Can't parse getRegistrationCode response"
            ShowMessageDialog()
            'ShowConnectionFailed()
            return ""
        endif

        Dbg("source:", xml.videos.video[0]@server)


        episode.Stream = { url: xml.videos.video[0]@server,
        bitrate:50000,
        quality:false,
        contentid:"mycontent-2000"
        }
        episode.StreamFormat = "mp4"
        screen.SetContent(episode)
        screen.SetMessagePort(port)
        screen.Show() 

        while true
           msg = wait(0, port)
           if type(msg) = "roVideoScreenEvent" then
               print "showVideoScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
               if msg.isScreenClosed()
                   print "Screen closed"
                   exit while
                else if msg.isStatusMessage()
                      print "status message: "; msg.GetMessage()
                else if msg.isPlaybackPosition()
                      print "playback position: "; msg.GetIndex()
                else if msg.isFullResult()
                      print "playback completed"
                      exit while
                else if msg.isPartialResult()
                      print "playback interrupted"
                      exit while
                else if msg.isRequestFailed()
                      print "request failed – error: "; msg.GetIndex();" – "; msg.GetMessage()
                      exit while
                end if
           end if
        end while 
    end if
End Function


Function GetAuthData() As Dynamic
     sec = CreateObject("roRegistrySection", "Authentication")
     if sec.Exists("UserIpToken") 
         return sec.Read("UserIpToken")
     endif
     return invalid
End Function

Function SetAuthData(userToken As String) As Void
    sec = CreateObject("roRegistrySection", "Authentication")
    sec.Write("UserIpToken", userToken)
    sec.Flush()
End Function
