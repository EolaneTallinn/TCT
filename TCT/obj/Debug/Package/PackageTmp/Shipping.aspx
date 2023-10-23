<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Shipping.aspx.cs" Inherits="TCT.Shipping" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <table style="width: 100%; vertical-align: top;">
    <tr>
        <td style="width: 280px; vertical-align: top;">

            <asp:RadioButtonList ID="StatusRadioButtonList" runat="server" OnSelectedIndexChanged="StatusRadioButtonList_SelectedIndexChanged" 
                AutoPostBack="True" RepeatDirection="Horizontal">
                <asp:ListItem Value="0" Text="Open" Selected="True" />
                <asp:ListItem Value="1" Text="Processed" />
                <asp:ListItem Value="2" Text="Closed" />
            </asp:RadioButtonList>
            Search: <asp:TextBox ID="SearchTextBox" runat="server" onkeyup="myfilter.set(this.value)" CssClass="grey" Width="120px" />
            <img src="Images/search.png" alt="Just type in the search field" />
            <asp:ImageButton ID="NewDocButton" runat="server" ImageUrl="~/Images/plus.jpg" onclick="NewDocButton_Click" ToolTip="Create a new Document" />
            <br /><br />
            <b>Document number &nbsp; ... (lines)</b><br />
            <asp:ListBox ID="ListBoxDocuments" runat="server" DataSourceID="SqlDataSource_ListBoxDocuments" OnSelectedIndexChanged="ListBoxDocuments_SelectedIndexChanged"
                DataTextField="DocNum" DataValueField="DocumentHeaderID" Height="450px" Width="250px" AutoPostBack="True">
            </asp:ListBox>
            <asp:SqlDataSource ID="SqlDataSource_ListBoxDocuments" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT dh.DocumentHeaderID, CAST(dh.DocumentHeaderID as varchar) + ' ... (' + CAST(count(dl.DocumentHeaderID) as varchar) + ')' as DocNum 
                    FROM Shipping.DocumentHeader dh LEFT JOIN Shipping.DocumentLine dl ON dh.DocumentHeaderID = dl.DocumentHeaderID 
                    WHERE dh.Status = @Status GROUP BY dh.DocumentHeaderID">
                <SelectParameters>
                    <asp:ControlParameter Name="Status" ControlID="StatusRadioButtonList" PropertyName="SelectedValue" />
                </SelectParameters>
            </asp:SqlDataSource>

        </td>
        <td style="vertical-align: top;">

            <asp:FormView ID="FormViewDocumentHeader" runat="server" DataKeyNames="DocumentHeaderID" DataSourceID="SqlDataSource_DocumentHeader">
                <ItemTemplate>
                    <table style="width: 100%;">
                        <tr><td>Document Number:</td>
                            <td><asp:Label ID="DocumentHeaderIDLabel" runat="server" Text='<%# Eval("DocumentHeaderID") %>' Font-Bold="true"/>
                            </td>
                            <td rowspan="6" style="width:30px;"></td>
                            <td>Declaration Number:</td>
                            <td><asp:Label ID="DeclarationNumberLabel" runat="server" Text='<%# Eval("DeclarationNumber") %>' Font-Bold="true"/>
                            </td>
                        </tr>
                        <tr><td>Create Date:</td>
                            <td><asp:Label ID="CreateDateLabel" runat="server" Text='<%# Eval("CreateDate") %>' Font-Bold="true"/>
                            </td>
                            <td>Declaration Date:</td>
                            <td><asp:Label ID="DeclarationDateLabel" runat="server" Text='<%# Eval("DeclarationDate") %>' Font-Bold="true"/>
                            </td>
                        </tr>
                        <tr><td>Document Type:</td>
                            <td><asp:Label ID="DocumentTypeLabel" runat="server" Text='<%# Eval("DocumentType2") %>' Font-Bold="true"/>
                            </td>
                            <td>Total Net Weight [g]:</td>
                            <td><asp:Label ID="TotalNetWeightLabel" runat="server" Text='<%# Eval("TotalNetWeight") %>' Font-Bold="true"/>
                            </td>
                        </tr>
                        <tr><td>Customs Code:</td>
                            <td><asp:Label ID="CustomsCodeLabel" runat="server" Text='<%# Eval("CustomsCode") %>' Font-Bold="true"/>
                            </td>
                            <td>Total Quantity:</td>
                            <td><asp:Label ID="TotalQuantityLabel" runat="server" Text='<%# Eval("TotalQuantity") %>' Font-Bold="true"/>
                            </td>
                        </tr>
                        <tr><td>Uljas Doc. no.:</td>
                            <td><asp:Label ID="UljasDocNumberLabel" runat="server" Text='<%# Eval("UljasDocNumber") %>' />
                            </td>
                            <td>Total Cost:</td>
                            <td><asp:Label ID="TotalCostLabel" runat="server" Text='<%# Eval("TotalCost") %>' Font-Bold="true"/>
                                &nbsp;
                                <asp:Label ID="Label1" runat="server" Text='<%# Eval("Currency") %>' Font-Bold="true"/>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
            </asp:FormView>

            <asp:SqlDataSource ID="SqlDataSource_DocumentHeader" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT DocumentHeaderID, UljasDocNumber, DeclarationNumber, CONVERT(varchar, DeclarationDate, 104) DeclarationDate, 
                        CONVERT(varchar, CreateDate, 104) CreateDate, CustomsCode, TotalNetWeight, TotalQuantity, 
                        ROUND(TotalCost,2) TotalCost, Currency, DocumentType, CASE DocumentType WHEN 1 THEN 'Products' WHEN 2 THEN 'Components' END as DocumentType2 
                    FROM Shipping.DocumentHeader WHERE DocumentHeaderID = @DocumentHeaderID"
                InsertCommand="INSERT INTO Shipping.DocumentHeader (CreateDate) VALUES (GETDATE())"
                UpdateCommand="UPDATE Shipping.DocumentHeader SET Status=2, DeclarationNumber = @DeclarationNumber, DeclarationDate=convert(datetime, @DeclarationDate, 104) WHERE DocumentHeaderID = @DocumentHeaderID">
                <SelectParameters>
                    <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" />
                    <asp:ControlParameter Name="DeclarationNumber" ControlID="DeclarationNumberTextBox" PropertyName="Text" />
                    <asp:ControlParameter Name="DeclarationDate" ControlID="DeclarationDateTextBox" PropertyName="Text" />
                </UpdateParameters>
            </asp:SqlDataSource>



            <asp:GridView ID="GridViewDocumentLine" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" GridLines="None" 
                DataKeyNames="DocumentLineID" DataSourceID="SqlDataSource_DocumentLine" OnSelectedIndexChanged="GridViewDocumentLine_SelectedIndexChanged">
                <AlternatingRowStyle BackColor="White" />
                <Columns>
                    <asp:CommandField ButtonType="Link" SelectText="X" ShowSelectButton="True"
                        ControlStyle-ForeColor="Red" ControlStyle-Font-Bold="true" ControlStyle-Font-Underline="false"/>
                    <asp:BoundField DataField="ItemID" HeaderText="ItemID" />
                    <asp:BoundField DataField="Description" HeaderText="Description" />
                    <asp:BoundField DataField="Quantity" HeaderText="Quantity" />
                    <asp:BoundField DataField="NetWeight" HeaderText="NetWeight" />
                    <asp:BoundField DataField="StdUnitCost" HeaderText="StdUnitCost" />
                </Columns>
                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                <RowStyle BackColor="#EFF3FB" />
            </asp:GridView>

            <asp:SqlDataSource ID="SqlDataSource_DocumentLine" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT DocumentLineID, ItemID, Description, Quantity, NetWeight, StdUnitCost 
                    FROM Shipping.DocumentLine WHERE (DocumentHeaderID = @DocumentHeaderID)"
                InsertCommand="Shipping.spDocumentLineInsert" InsertCommandType="StoredProcedure"
                DeleteCommand="Shipping.spDocumentLineDelete" DeleteCommandType="StoredProcedure">
                <SelectParameters>
                    <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" />
                </SelectParameters>
                <InsertParameters>
                    <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" Type="Int32" />
                    <asp:ControlParameter Name="ProformaInvoiceLineID" ControlID="GridViewProformaInvoiceLines" PropertyName="SelectedValue" Type="Int32" />
                    <asp:ControlParameter Name="ItemID" ControlID="ItemIDDropDownList" PropertyName="SelectedValue" Type="String" />
                    <asp:ControlParameter Name="Quantity" ControlID="QuantityTextBox" PropertyName="Text" Type="Double" />
                </InsertParameters>
                <DeleteParameters>
                    <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" Type="Int32" />
                    <asp:ControlParameter Name="DocumentLineID" ControlID="GridViewDocumentLine" PropertyName="SelectedValue" Type="Int32" />
                </DeleteParameters>
            </asp:SqlDataSource>


            <asp:PlaceHolder ID="PlaceHolderPrintDocument" runat="server" Visible="false">
                <br />
                <asp:Button ID="PrintDocumentButton" runat="server" PostBackUrl="~/PrintDocument.aspx" Text="Print Document" />
                    <%-- OnClientClick="window.document.forms[0].target='_blank';" --%>
            </asp:PlaceHolder>


            <asp:PlaceHolder ID="PlaceHolderClosingForm" runat="server" Visible="false">
                <br /><br />
                <table>
                    <tr><td>Declaration Number:</td>
                        <td><asp:TextBox ID="DeclarationNumberTextBox" runat="server" CssClass="grey" EnableViewState="False" />
                            <asp:RequiredFieldValidator ID="ReqFieldValidatorDeclarationNumber" runat="server" ErrorMessage="* Required field"
                                ControlToValidate="DeclarationNumberTextBox" ValidationGroup="CloseDocument" CssClass="red" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr><td>Declaration Date:</td>
                        <td><asp:TextBox ID="DeclarationDateTextBox" runat="server" CssClass="grey" EnableViewState="False" />
                            <asp:RequiredFieldValidator ID="ReqFieldValidatorDeclarationDate" runat="server" ErrorMessage="* Required field"
                                ControlToValidate="DeclarationDateTextBox" ValidationGroup="CloseDocument" CssClass="red" Display="Dynamic" />
                            <ajax:CalendarExtender ID="DeclarationDateCalendarExtender" runat="server" TargetControlID="DeclarationDateTextBox" 
                                FirstDayOfWeek="Monday" Format="dd.MM.yyyy">
                            </ajax:CalendarExtender>
                        </td>
                    </tr>
                    <tr><td></td>
                        <td><asp:Button ID="CloseDocumentButton" runat="server" CausesValidation="True" Text="Close Document" ValidationGroup="CloseDocument" OnClick="CloseDocumentButton_Click"/>
                        </td>
                    </tr>
                </table>
            </asp:PlaceHolder>

            <%--///////////////////////////////////////////////--%>
            <%--         PROFORMA INVOICE PLACE HOLDER         --%>
            <%--///////////////////////////////////////////////--%>
            
            <asp:PlaceHolder ID="PlaceHolderProformas" runat="server" Visible="false">

                <asp:Button ID="ProcessButton" runat="server" Text="Process Document" OnClick="ProcessButton_Click" 
                    OnClientClick="if (!window.confirm('Process document and deduct components from stock?')) return false;" />
                <asp:SqlDataSource ID="SqlDataSource_ProcessButton" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    UpdateCommand="Customs.spDecreseStockByDocumentHeader" UpdateCommandType="StoredProcedure">
                    <UpdateParameters>
                        <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" Type="Int32" />
                    </UpdateParameters>
                </asp:SqlDataSource>
                <br />

                <h3>Add lines:</h3>

                Timeframe:
                <asp:DropDownList ID="BillingDateDropDownList" runat="server" CssClass="grey" AutoPostBack="true">
                    <asp:ListItem Value="30" Text="Last 30 days" />
                    <asp:ListItem Value="183" Text="Last 6 months" />
                    <asp:ListItem Value="365" Text="Last 12 months" />
                </asp:DropDownList>

                Customs Code:
                <asp:DropDownList ID="CustomsCodeDropDownList" runat="server" CssClass="grey" AutoPostBack="True"
                    DataSourceID="SqlDataSource_CustomsCode" DataTextField="CustomsCode" DataValueField="CustomsCode" />
                <asp:SqlDataSource ID="SqlDataSource_CustomsCode" runat="server" CancelSelectOnNullParameter="false"
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT DISTINCT CustomsCode FROM Customs.Items WHERE @CustomsCode IS NULL OR CustomsCode = @CustomsCode ORDER BY CustomsCode">
                    <SelectParameters>
                        <asp:Parameter Name="CustomsCode" /><%-- Value is set via SetFilterForAddingNewLines() --%>
                    </SelectParameters>
                </asp:SqlDataSource>
                
                <asp:GridView ID="GridViewProformaInvoiceLines" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" GridLines="None" 
                    DataKeyNames="ProformaInvoiceLineID" DataSourceID="SqlDataSource_ProformaInvoiceLines" AllowPaging="True" ShowHeaderWhenEmpty="True" 
                    OnSelectedIndexChanged="GridViewProformaInvoiceLines_SelectedIndexChanged">
                    <AlternatingRowStyle BackColor="White" />
                    <EmptyDataTemplate><span class="red">- No unhandled invoices (SAP deliveries) found during the <%= BillingDateDropDownList.SelectedItem %></span></EmptyDataTemplate>
                    <Columns>
		                <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button runat="server" ID="btnSelect" CommandName="Select" Text="Pick" Enabled='<%# Eval("CustomsCode").ToString().Length.Equals(10) && !Eval("Weight").ToString().Equals("0") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ProformaInvoiceLineID" Visible="False" /> 
		                <asp:BoundField DataField="ProformaInvoiceNumber" HeaderText="InvoiceNumber" />
		                <asp:BoundField DataField="BillingDate" HeaderText="BillingDate" DataFormatString="{0:dd.MM.yyyy}" />
		                <asp:BoundField DataField="ItemID" HeaderText="Item" ItemStyle-ForeColor="#003366" ItemStyle-Font-Bold="true" />
		                <asp:BoundField DataField="Quantity" HeaderText="Quantity" />
		                <asp:BoundField DataField="CustomsCode" HeaderText="CustomsCode" />
		                <asp:BoundField DataField="Description" HeaderText="Description" />
		                <asp:BoundField DataField="Weight" HeaderText="NetWeight" />
		                <asp:BoundField DataField="WeightUnit" HeaderText="WeightUnit"  />
		                <asp:BoundField DataField="StdUnitCost" HeaderText="UnitCost" />
		                <asp:BoundField DataField="Currency" HeaderText="Currency" />
                    </Columns>
                    <RowStyle BackColor="#EFF3FB" />
                    <HeaderStyle BackColor="#336666" Font-Bold="True" ForeColor="White" />
                    <FooterStyle BackColor="#336666" Font-Bold="True" ForeColor="White" />
                </asp:GridView>
            
                <asp:SqlDataSource ID="SqlDataSource_ProformaInvoiceLines" runat="server" CancelSelectOnNullParameter="false"
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT pr.ProformaInvoiceLineID, pr.ProformaInvoiceNumber, pr.ProformaInvoiceLineNumber, pr.ItemID, pr.BillingDate, pr.Quantity, 
                    item.[Description], item.[Weight], item.WeightUnit, item.StdUnitCost, item.Currency, item.CustomsCode
                    FROM Shipping.ProformaInvoice pr
                        INNER JOIN Customs.OpenStockItems s ON pr.ItemID = s.ItemID
                        LEFT JOIN Customs.Items item ON pr.ItemID = item.ItemCode
                    WHERE pr.IsProcessed = 0
                        AND pr.BillingDate &gt; GETDATE()-CAST(@BillingDateDiff as int)
                        AND (@CustomsCode IS NULL OR (item.CustomsCode = @CustomsCode OR item.CustomsCode IS NULL) ) 
                        AND (@DocumentType = '0' OR (LEN(pr.ItemID) = CASE @DocumentType WHEN '1' THEN 6 WHEN '2' THEN 8 END) )
                    ORDER BY pr.BillingDate DESC">
                    <%--  NOTE:  This: "LEN(ItemID) = CASE @DocumentType WHEN '1' THEN 6 WHEN '2' THEN 8 END" in the above query
                                 may cause bugs in the future  IF  the product code goes 7-digit, or component code goes 9-digit
                    --%>
                    <SelectParameters>
                        <asp:ControlParameter Name="DocumentHeaderID" ControlID="ListBoxDocuments" PropertyName="SelectedValue" />
                        <asp:ControlParameter Name="CustomsCode" ControlID="CustomsCodeDropDownList" PropertyName="SelectedValue" />
                        <asp:Parameter Name="DocumentType" /><%-- Value is set via SetFilterForAddingNewLines() --%>
                        <asp:ControlParameter Name="BillingDateDiff" ControlID="BillingDateDropDownList" PropertyName="SelectedValue" />
                    </SelectParameters>
                </asp:SqlDataSource>

                <h3>Add a line manually:</h3>
                <table>
                    <tr><td>Customs Code:</td>
                        <td><asp:Label ID="CustomsCodeLabel" runat="server" Font-Bold="true"><%= CustomsCodeDropDownList.SelectedValue %></asp:Label>
                            <asp:RequiredFieldValidator ID="ReqFieldValidatorCustomsCode" runat="server" ErrorMessage="* Please select a Customs Code from the drop down list above"
                                ControlToValidate="CustomsCodeDropDownList" ValidationGroup="AddManualLine" CssClass="red" InitialValue="" />
                        </td>
                    </tr>
                    <tr><td>Item Code:</td>
                        <td><asp:DropDownList ID="ItemIDDropDownList" runat="server" CssClass="grey" 
                                DataSourceID="SqlDataSource_ItemID" DataTextField="ItemCode" DataValueField="ItemCode" />
                            <asp:SqlDataSource ID="SqlDataSource_ItemID" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                SelectCommand="SELECT ItemCode FROM Customs.Items WHERE CustomsCode = @CustomsCode 
                                    AND ( @DocumentType = '0' OR (LEN(ItemCode) = CASE @DocumentType WHEN '1' THEN 6 WHEN '2' THEN 8 END) )
                                    ORDER BY ItemCode">
                                <SelectParameters>
                                    <asp:ControlParameter Name="CustomsCode" ControlID="CustomsCodeDropDownList" PropertyName="SelectedValue" />
                                    <asp:Parameter Name="DocumentType" /><%-- Value is set via SetFilterForAddingNewLines() --%>
                                </SelectParameters>
                            </asp:SqlDataSource>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorItemID" runat="server" ErrorMessage="* Required field"
                                ControlToValidate="ItemIDDropDownList" ValidationGroup="AddManualLine" CssClass="red" Display="Dynamic" />
                        </td>
                    </tr>
                    <tr><td>Quantity:</td>
                        <td><asp:TextBox ID="QuantityTextBox" runat="server" CssClass="grey" />
                            <asp:RequiredFieldValidator ID="ReqFieldValidatorQuantity" runat="server" ErrorMessage="* Required field"
                                ControlToValidate="QuantityTextBox" ValidationGroup="AddManualLine" CssClass="red" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="RegExValidatorQuantity" runat="server" ErrorMessage="* Please insert a number"
                                ControlToValidate="QuantityTextBox" ValidationGroup="AddManualLine" CssClass="red"  Display="Dynamic" ValidationExpression="^\d+$"/>
                        </td>
                    </tr>
                    <tr><td></td>
                        <td><asp:Button ID="AddManualLineButton" runat="server" Text="Add Line" 
                                CausesValidation="True" ValidationGroup="AddManualLine" OnClick="AddManualLineButton_Click"/>
                        </td>   
                    </tr>
                </table>
                
            </asp:PlaceHolder>
        </td>
    </tr>
</table>
</asp:Content>
