*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Robocorp.Vault

*** Variables ***

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    @{orders}=    Get orders
    FOR    ${row}    IN    @{orders}
            Close the annoying modal
            Fill the form    ${row}
            Preview the robot  
            Wait Until Keyword Succeeds    4x    500ms     Submit the order
            ${pdfName}=    Store the receipt as a PDF file    ${row}[Order number]
            ${screenshot}=    Take a screenshot of the robot
            Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdfName}
            Go to order another robot
    END
    Create a ZIP file of the receipts
    [Teardown]    Close Browser

*** Keywords ***
Open the robot order website
    ${URLpaths} =     Get Secret    URLpaths
    Open Available Browser     ${URLpaths}[BrowserPath]   


Get orders
    ${URLpaths} =     Get Secret    URLpaths
    Download   ${URLpaths}[ExcelPath]   overwrite=True
    @{table}=   Read table from CSV    orders.csv
    RETURN     @{table}

Close the annoying modal
    Click Element If Visible    //button[contains(.,'OK')]
    Wait Until Element Is not Visible     class:modal-dialog

Fill the form 
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    //label[contains(.,'3. Legs:')]/../input    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Click Button    order
    Assert page Contains Error

Store the receipt as a PDF file  
    [Arguments]    ${orderNo}
    Wait Until Element Is Visible    id:receipt
    ${receipt-details}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt-details}    ${OUTPUT_DIR}/Orders/Order-${orderNo}.pdf 
    RETURN    ${OUTPUT_DIR}/Orders/Order-${orderNo}.pdf

Take a screenshot of the robot  
    Capture Element Screenshot    robot-preview-image    ${OUTPUT_DIR}/image.png
    RETURN    ${OUTPUT_DIR}/image.png

Embed the robot screenshot to the receipt PDF file 
    [Arguments]  ${screenshot}    ${pdfName}
     ${files}=    Create List    ${screenshot}:align=center          

    Add Files To Pdf  ${files}    ${pdfName}    append=True
    

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip      ${OUTPUT_DIR}/Orders/     ${OUTPUT_DIR}/Orders/Orders.Zip


Assert page Contains Error
    Page Should Not Contain Element    class:alert-danger