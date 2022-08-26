*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Robocorp.Vault


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    ${secret}=    Get Secret    credentials
    Open Available Browser    ${secret}[url]

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true
    ${orders}=    Read table from CSV    orders.csv    header=true
    RETURN    ${orders}

Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath://*[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Wait Until Element Is Visible    id:robot-preview-image
    Click Button    order
    Click Element If Visible    id:order

Store the receipt as a PDF file
    [Arguments]    ${orderNumber}
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts/receipt_${orderNumber}.pdf
    ${pdf}=    Set Variable    ${OUTPUT_DIR}${/}receipts/receipt_${orderNumber}.pdf
    RETURN    ${pdf}

Take a screenshot of the robot
    [Arguments]    ${orderNumber}
    ${screenshot}=    Screenshot
    ...    xpath://*[@id="robot-preview-image"]
    ...    ${OUTPUT_DIR}${/}Screenshot/robot_${orderNumber}.png
    ${screenshot}=    Set Variable    ${OUTPUT_DIR}${/}Screenshot/robot_${orderNumber}.png
    RETURN    ${screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${file}=    Create List    ${screenshot}
    Add Files To Pdf    ${file}    ${pdf}    append=true
    Close Pdf

Go to order another robot
    Wait Until Element Is Visible    id:order-another
    Click Button    order-another

Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${zip_file_name}
