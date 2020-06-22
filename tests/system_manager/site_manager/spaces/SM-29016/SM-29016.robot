*** Settings ***
Library   ../../../../../py_sources/logigear/setup.py               
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/AdministrationPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/spaces/AdmGeomapOptionsPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
        
Resource    ../../../../../resources/constants.robot

Default Tags    Spaces    
Force Tags    SM-29016

*** Variables ***
${URL_TEMPLATE} =    https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}
${TEXT1} =    Google
${URL_LINK_1} =    https://www.google.com/maps
${TEXT2} =    Google guidelines
${URL_LINK_2} =    https://www.google.com/permissions/geoguidelines/
${MISSING_FIELD_ERR_MSG} =    Complete all required fields. Required fields are marked with *.
${INVALID_ZOOM_NUMBER_ERR_MSG} =    Enter a number between 1 and 23 for Maximum Zoom Level.
${MISS_ATTR_LINK_ERR_MSG} =    At least 1 Attribution Link item is required.

*** Test Cases ***
[Bulk SM-29016-01->11] Verify that a new configue page "GeoMap Options" is added in to Administrartion tab -> Spaces category
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    ...    AND    Select Main Menu    ${Administration}/${Spaces}
    ...    AND    Go To Geomap Options
    ...    AND    Fill Custom Geomap Map View    ${EMPTY}    1    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    AND    Set Custom Geomap Server Map View    ${False}
    ...    AND    Fill Custom Geomap Satellite View    ${EMPTY}    1    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY} 
    ...    AND    Set Custom Geomap Server Satellite View    ${False}    ${True}    ${True}   
    ...    AND    Select Main Menu    ${Site Manager}
    
    [Teardown]    Run Keywords       Select Main Menu    ${Administration}/${Spaces}
    ...    AND    Go To Geomap Options
    ...    AND    Fill Custom Geomap Map View    ${EMPTY}    1    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    AND    Set Custom Geomap Server Map View    ${False}
    ...    AND    Fill Custom Geomap Satellite View    ${EMPTY}    1    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY} 
    ...    AND    Set Custom Geomap Server Satellite View    ${False}    ${True}    ${True}
    ...    AND    Close Browser
    
    [Tags]    Sanity
   
    # 3. Go to Site Manager, Select Site
    # 4. Click "Spaces" icon to go to Spaces view
    # 5. Observe the result
    Click Tree Node On Site Manager    ${SITE_NODE}
    Go To Another View On Site Manager    ${Spaces}
    
    # VP:_GeoMap displays on Spaces with Map view
    #    _ Attribution Link on the Bottom-Right Show: @MapTiler @Open StreetMap Contribution
    Check Map Div Display
    Check Maptiler Link Display
    Check Openstreetmap Link Display
    
    # 6. Click "Satellite View" icon
    # 7. Observe the result.
    Switch Geomap View    Satellite
    
    # VP: _GeoMap displays on Spaces with Satellite view
    #     _ Attribution Link on the Bottom-Right Show: @MapTiler @Open StreetMap Contribution
    Check Map View Button Display
    Check Map Div Display
    Check Maptiler Link Display
    Check Openstreetmap Link Display
    
    # 8. Click "Map View" icon
    # 9. Observe the result.
    Switch Geomap View    Map
    
    # VP: _GeoMap back to Map View
    Check Satellite View Button Display
    Check Map Div Display
    Check Maptiler Link Display
    Check Openstreetmap Link Display
    
    # 3. Click on "Hide Tree"/ "Show Tree button to hide/show site tree
    ${left_satellite_btn_before_hide} =    Get Satellite View Button Horizontal Position 
    Show Tree    ${False}
    
    # 4. Observe the result
    # VP: Satellite View icon is move and keep at botom-left of Geo if user hide/show Site tree
    ${left_satellite_btn_after_hide} =    Get Satellite View Button Horizontal Position 
    Should Be True    ${left_satellite_btn_after_hide} < ${left_satellite_btn_before_hide}
    
    Show Tree    ${True}
    
    # 5. Click on Satellite View icon
    Switch Geomap View    Satellite
    
    # 6. Click on "Hide Tree"/ "Show Tree button to hide/show site tree
    ${left_map_btn_before_hide} =    Get Map View Button Horizontal Position
    Show Tree    ${False}
    
    # 7. Observe the result
    # VP: Map View icon is move and keep at botom-left of Geo if user hide/show Site tree
    ${left_map_btn_after_hide} =    Get Map View Button Horizontal Position
    Should Be True    ${left_map_btn_after_hide} < ${left_map_btn_before_hide}
    
    #Switch Back to Map View and restore tree
    Show Tree    ${True}
    Switch Geomap View    Map
    
    # 1. Go to Administration
    # 2. Observe new configure page in Space category
    # VP: There is a GeoMap Options in Spaces category (under Layer Image Files)
    Select Main Menu    ${Administration}
    Check Geomap Options Link Displays
    
    #3. Click "GeoMap Options" to go to GeoMap Options page
    Go To Geomap Options
    
    # 4. Observe the UI of page
    # All fields are greyed out as default
    # The options are grouped with two sections, one is Map view and another is Satellite view
    # The GeMap Options page displays as below:
    # _ Check box with label: "Use Custom GeoMap Server - Map View" (uncheck as default)
    # _ "Maximum Zoom Level" field (1-23)
    # _ "Attribution Link"
    # + "Text" and " URL Link"
    # + Text field and URL link field (3 rows)
    
    Check Custom Geomap Server Map View State    ${False}
    Check Custom Geomap Satellite View State    ${False}
    
    # 5. Check and uncheck "Use Custom GeoMap Server -Map View" checkbox and observe the result
    # VP: All field of Map View Section are actived if checkbox is checked
    
    Set Custom Geomap Server Map View    ${True}
    Check Custom Geomap Server Map View State    ${True}
    
    # 6. Check and uncheck "Use Custom GeoMap Server -Satellite View" checkbox and observe the result
    # VP: All field of Satellite View Section are actived if checkbox is checked
    Set Custom Geomap Server Satellite View    ${True}
    Check Custom Geomap Satellite View State    ${True}
    
    # 4. Uncheck 1 in 2 check boxes and click save
    Set Custom Geomap Server Satellite View    ${False}    ${True}
    
    # 5. Observe the result.
    # VP: User cannot save with error message: "Complete all required fields. Required fields are marked with *."
    Check Popup Error Message    ${MISSING_FIELD_ERR_MSG}    yes
    
    # 6. Check on 2 check boxes, Enter valid value for each field except URL template
    # 7. click save and observe the result
    Fill Custom Geomap Map View    ${EMPTY}    1         
    Fill Custom Geomap Satellite View    ${EMPTY}    3    save=${True}
    
    # VP: User cannot save with error message: "Complete all required fields. Required fields are marked with *."
    Check Popup Error Message    ${MISSING_FIELD_ERR_MSG}    yes 
    
    # 3. Try to enter invalid number for "Maximum Zoom Level" field out of ranges from 1->23
    # 4.Click Save and observe the result
    # VP: User cannot save with error message: "Enter a number between 1 and 23 for Maximum Zoom Level."
    Fill Custom Geomap Map View    ${URL_TEMPLATE}    0    save=${True}
    Check Popup Error Message    ${INVALID_ZOOM_NUMBER_ERR_MSG}    yes
           
    Fill Custom Geomap Satellite View    ${URL_TEMPLATE}    24    save=${True}
    Check Popup Error Message    ${INVALID_ZOOM_NUMBER_ERR_MSG}    yes
    
     # 3. Enter value as below:
        # _URL Template *: https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}
        # _Maximum Zoom Level *: 10
        # _Attribution Link:
    # 4. Click save and observe the result
    Fill Custom Geomap Map View    ${URL_TEMPLATE}    10    save=${True}
    Check Popup Error Message    ${MISS_ATTR_LINK_ERR_MSG}    yes
               
    Fill Custom Geomap Satellite View    ${URL_TEMPLATE}    10    save=${True}
    Check Popup Error Message    ${MISS_ATTR_LINK_ERR_MSG}    yes
    
    # 4. Enter value for each fields as below:
    # _Use Custom GeoMap Server - Map View
        # URL Template *: https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}
        # Maximum Zoom Level *: 1
        # Attribution Link"
            # Text: @Google || URL Link: https://www.google.com/maps
            # Text: @Google guidelines || URL Link: https://www.google.com/permissions/geoguidelines/
    # _Use Custom GeoMap Server - Satellite View
        # URL Template *: https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}
        # Maximum Zoom Level *: 20
        # Attribution Link"
            # Text: @Google || URL Link: https://www.google.com/maps
            # Text: @Google guidelines || URL Link: https://www.google.com/permissions/geoguidelines/
    
    Fill Custom Geomap Map View    ${URL_TEMPLATE}    1    ${TEXT1}    ${URL_LINK_1}    ${TEXT2}    ${URL_LINK_2}           
    Fill Custom Geomap Satellite View    ${URL_TEMPLATE}    3    ${TEXT1}    ${URL_LINK_1}    ${TEXT2}    ${URL_LINK_2}    None    None    ${True}    ${True}        
    
    # 5. Save and Return to Site Manager
    Select Main Menu    ${Site Manager}   

    # 6. Select Site and switch to Spaces view
    Click Tree Node On Site Manager    ${SITE_NODE}
    Go To Another View On Site Manager    ${Spaces}
    
    # Restore map to original state
    Zoom Map    out    1  

    # 7. Observe the Geo in Map View
    # VP: _ Geo Show Google Map View
    #     _ @Google and @Google guidelines hyperlink show on the bottom-right of Geo (user can access these links via clicking on its)
    Check Google Link Display
    Check Googleguidelines Link Display
    
    # 8.Try to Click "Zoom In/ Zoom Out" icon and observe the result
    # VP: Geo cannot Zoom In/out because Zoom Level is set as 1
    Check Map Unzoomable    in    1
    
    # 9. Click "Satellite View" icon
    Switch Geomap View    Satellite
    
    # Restore map to original state
    Zoom Map    out    1
       
    # 10. Observe the Geo in Satellite View
    # VP: _ Geo Show Google Satellite View
    #     _ @Google and @Google guidelines hyperlink show on the bottom-right of Geo (user can access these links via clicking on its)
    Check Google Link Display
    Check Googleguidelines Link Display
    
    # 11.Try to Click "Zoom In/ Zoom Out" icon and observe the result
    # VP: Geo can Zoom In 19 times then Zoom Out 19 Times because Zoom Level is set as 20
    
    Check Map Zoomable    in    2
    
    # (user can access these links via clicking on its)
    Click Google Link
    ${handle}=    Switch Window    NEW
    Check Current Window Title    Google Maps
    
    # switch back to SM window
    Switch Window    ${handle}  

    Click Googleguidelines Link
    Switch Window    NEW
    Check Current Window Title Contain    Permission  
    Check Current Window Title Contain    Google 
    
    # switch back to SM window for running teardown
    Switch Window    ${handle}
