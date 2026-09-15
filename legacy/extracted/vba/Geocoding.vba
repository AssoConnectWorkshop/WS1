Attribute VB_Name = "Geocoding"
Option Compare Database
Option Explicit

'Public Type containing the geocoding of the postal address
Public Type tGeocodeResult
   dLatitude As Double
   dLongitude As Double
   sRetAddress As String
   sAccuracy As String
   sStatus As String
End Type

'---------------------------------------------------------------------------------------
' Procedure : Geocode with Google Geocoding API v3
' Version   : 1.01
' DateTime  : 03/03/2011
' Author    : Philben
' Purpose   : converting addresses into geographic coordinates
' Parameter : No mandatory. string format or NULL
' Reference : http://code.google.com/intl/fr-FR/apis/maps/documentation/geocoding/index.html
' Remark    : Query limit of 2,500 geolocation requests per day
'           : A good accuracy is different of a good geocoding !!!
'           : Minimum delay between two queries : >= 200 ms
'---------------------------------------------------------------------------------------
Public Function Geocode(Optional ByVal vAddress As Variant = Null, _
                        Optional ByVal vTown As Variant = Null, _
                        Optional ByVal vPostCode As Variant = Null, _
                        Optional ByVal vRegion As Variant = Null, _
                        Optional ByVal sCountry As String = "FRANCE") As tGeocodeResult
   On Error GoTo catch
   Dim oXmlDoc As Object
   Dim sUrl As String, sFormatAddress As String

   If Not IsNull(vAddress) Then vAddress = Replace(vAddress, ",", " ")
   sFormatAddress = (vAddress + ",") & _
                    (vTown + ",") & _
                    (vRegion + ",") & _
                    (vPostCode + ",") & _
                    sCountry

   'To create the URL
   sUrl = "http://maps.googleapis.com/maps/api/geocode/xml?address=" & sFormatAddress & "&sensor=false"

   ''XMLDOM to get the XML response
   Set oXmlDoc = CreateObject("Microsoft.XMLDOM")
   With oXmlDoc
      .Async = False
      If .Load(sUrl) And Not .selectSingleNode("GeocodeResponse/status") Is Nothing Then
         'Status code
         Geocode.sStatus = .selectSingleNode("GeocodeResponse/status").Text

         'If a result is returned
         If Not .selectSingleNode("GeocodeResponse/result") Is Nothing Then

            'formatted_address
            Geocode.sRetAddress = .selectSingleNode("//formatted_address").Text

            'Accuracy
            Geocode.sAccuracy = .selectSingleNode("//location_type").Text

            'Latitude and longitude
            Geocode.dLatitude = Val(.selectSingleNode("//location/lat").Text)
            Geocode.dLongitude = Val(.selectSingleNode("//location/lng").Text)
         End If
      End If
   End With
   Set oXmlDoc = Nothing
   Exit Function
catch:
   Set oXmlDoc = Nothing
   err.Raise err.Number, , err.Description
End Function

