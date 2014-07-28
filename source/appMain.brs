'********************************************************************
'**  Video Player Example Application - Main
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'********************************************************************

Sub Main()

    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    'prepare the screen for display and get ready to begin
    screen=preShowHomeScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowHomeScreen"
        return
    end if
    data = "192.168.0.105"
    'SetAuthData(data)
    Dbg("contains:", GetAuthData())
    data = GetAuthData()
    if data=invalid then
      Dbg("Must define ip")
    end if

    'set to go, time to get started
    'showHomeScreen(screen)
    aa1 = CreateObject("roAssociativeArray")
    aa1 = {
    
    }
    'showVideoScreen2(aa1)
    moviePoster()
    

End Sub


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"

    theme.OverhangOffsetHD_X = "125"
    theme.OverhangOffsetHD_Y = "35"
    theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"

    app.SetTheme(theme)

End Sub

Function moviePoster()
    port = CreateObject("roMessagePort")
    springBoard = CreateObject("roSpringboardScreen")
    springBoard.SetBreadcrumbText("TorrenTV", "Roku")
    springBoard.SetMessagePort(port) 
    o = CreateObject("roAssociativeArray")
    o.ContentType = "episode"
    o.Title = "TorrenTV Streaming App for Roku"
    o.Description = "Drag and drop your Torrent to the application in your computer and then click 'Start playing now!'."
    o.SDPosterUrl = "pkg:/images/posterHD.png"
    o.HDPosterUrl = "pkg:/images/posterHD.png"
    o.Categories = CreateObject("roArray", 10, true) 
    
    ip = GetAuthData()
    if ip=invalid then
      ip = "192.168.0.100"
    end if
    o.Categories.Push("TorrenTV running in: "+ip)
    o.Actors = CreateObject("roArray", 10, true)
    o.Actors.Push("TorrenTV Roku Player")
    o.StarRating = "100"
    springBoard.SetContent(o)
    springBoard.AddButton(0, "Start playing now!")
    springBoard.AddButton(1, "Set up")
    springBoard.Show()
    While True
        msg = wait(0, port)
        If msg.isScreenClosed() Then
            Return -1
        Elseif msg.isButtonPressed() 
            If msg.GetIndex()=0 then
            aa1 = CreateObject("roAssociativeArray")
            print "msg: "; msg.GetMessage(); "idx: "; msg.GetIndex()
            showVideoScreen2(aa1)
            end if
            If msg.GetIndex()=1 then
                Setup()
            end if



        Endif
    End While
End Function


Function Setup() 
     screen = CreateObject("roKeyboardScreen")
     port = CreateObject("roMessagePort") 
     screen.SetMessagePort(port)
     screen.SetTitle("Set TorrenTV IP")
     screen.SetText("192.168.0.100")
     ip = GetAuthData()
     if ip=invalid then
         screen.SetText("192.168.0.100")
     else
         screen.SetText(ip)
     end if
     screen.SetDisplayText("Write the IP from TorrenTV application.")
     screen.SetMaxLength(16)
     screen.AddButton(1, "finished")
     screen.AddButton(2, "back")
     screen.Show() 
  
     while true
         msg = wait(0, screen.GetMessagePort()) 
         print "message received"
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isScreenClosed()
                 return -1
             else if msg.isButtonPressed() then
                 print "Evt:"; msg.GetMessage ();" idx:"; msg.GetIndex()
                 if msg.GetIndex() = 1
                     searchText = screen.GetText()
                     SetAuthData(searchText)
                     print "search text: "; searchText 
                     moviePoster()
                     'return -1
                 endif
             endif
         endif
     end while 
End Function 


Function ShowMessageDialog() As Void 
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port) 
    dialog.SetTitle("Could not connect")
    ip = GetAuthData() 
    dialog.SetText("Connection to "+ip+" couldn't be done, please check setup")
 
    dialog.AddButton(1, "Got it!")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while 
End Function
