<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GateReg.aspx.cs" Inherits="TCT.GateReg" meta:resourcekey="PageResource1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/jscript" language="javascript">
        function ShowHide(Id) {
            g = document.getElementById(Id);
            if (g.className == 'hidden') {
                g.className = '';
            } else {
                g.className = 'hidden';
            }
        }
        function BeforePostbackScroll() {
            document.getElementById('<%= savePosition.ClientID %>').value = document.getElementById('<%= ListBox1.ClientID %>').scrollTop;
        }
        function AfterPostScroll() {
            if (document.getElementById('<%= savePosition.ClientID %>').value.length > 0) {
                document.getElementById('<%= ListBox1.ClientID %>').scrollTop = parseInt(document.getElementById('<%= savePosition.ClientID %>').value);
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <table style="width: 100%; vertical-align: top;">
    <tr>
        <td style="width: 280px; vertical-align: top;">
            <asp:Label ID="SearchLabel" runat="server" Text="Search:" meta:resourcekey="SearchLabelResource1"/>
            <asp:TextBox ID="SearchTextBox" runat="server" onkeyup="myfilter.set(this.value)" CssClass="grey" Width="130px" />
            <img src="Images/search.png" alt="Just type in the search field" />
            <asp:ImageButton ID="BtnNewGR" runat="server" ImageUrl="~/Images/plus.jpg" 
                OnClick="BtnNewGR_Click" ToolTip="Create a new Gate Registration" meta:resourcekey="BtnNewGRResource1" />
            <br /><br />
            <asp:Label ID="ListBox1HeaderLabel" runat="server" Text="G.R. id / Forwarder &nbsp; (lines)" Font-Bold="true" meta:resourcekey="ListBox1HeaderLabelResource1"/>
            <br />
            <asp:ListBox ID="ListBox1" runat="server" DataSourceID="SqlDataSource_ListBox1" DataTextField="TextCol" DataValueField="DeliveryID" 
                Height="450px" Width="250px" AutoPostBack="True" onselectedindexchanged="ListBox1_SelectedIndexChanged" />
            <br />
            <input type="hidden" id="savePosition" name="savePosition" runat="server"/>
            <asp:CheckBox ID="ShowAllCheckBox" runat="server" Text="Show all" 
                AutoPostBack="True" OnCheckedChanged="ShowAllCheckBox_CheckedChanged" 
                meta:resourcekey="ShowAllCheckBoxResource1"/>
            <asp:SqlDataSource ID="SqlDataSource_ListBox1" runat="server" CancelSelectOnNullParameter="False"
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT h.DeliveryID, CAST(h.DeliveryID AS varchar) + '. ' + f.Name + ' (' + CAST(COUNT(l.DeliveryLineID) as varchar) + ' lines)' as TextCol 
                    FROM Delivery.DeliveryHeader h 
                    LEFT JOIN Delivery.DeliveryLine l ON h.DeliveryID = l.DeliveryID
                    LEFT JOIN Delivery.Forwarder f ON h.ForwarderID = f.ForwarderID
                    WHERE (@ShowAll = 1  OR  h.CreateDate &gt; GETDATE()-@NumOfDays)
                        AND  (@FreightBillNumber IS NULL  OR  l.FreightBillNumber = @FreightBillNumber)
                    GROUP BY h.DeliveryID, f.Name, h.CreateDate  ORDER BY h.CreateDate DESC">
                <SelectParameters>
                    <asp:ControlParameter Name="ShowAll" ControlID="ShowAllCheckBox" PropertyName="Checked" />
                    <asp:Parameter Name="NumOfDays" DefaultValue="60" Type="Int32" />
                    <asp:Parameter Name="FreightBillNumber" />
                </SelectParameters>
            </asp:SqlDataSource>

        </td>
        <td style="vertical-align: top;">

            <asp:FormView ID="FormViewDeliveryHeader" runat="server" DefaultMode="Edit" 
                DataKeyNames="DeliveryID" DataSourceID="SqlDataSource_FormViewDeliveryHeader" 
                OnItemInserted="FormViewDeliveryHeader_ItemInserted" OnItemUpdated="FormViewDeliveryHeader_ItemUpdated" OnDataBound="FormViewDeliveryHeader_DataBound">
                <EditItemTemplate>
                    <table style="width: 100%;">
                        <tr><td><asp:Label ID="DHeadDeliveryIDLabel" runat="server" Text="Gate Registration ID:" meta:resourcekey="DHeadDeliveryIDLabelResource1" /></td>
                            <td><asp:Label ID="DeliveryIDLabel" runat="server" Text='<%# Eval("DeliveryID") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadCreateDateLabel" runat="server" Text="Create Date:" meta:resourcekey="DHeadCreateDateLabelResource1" /></td>
                            <td><asp:Label ID="CreateDateLabel" runat="server" Text='<%# Bind("CreateDate") %>' /> &nbsp;&nbsp;
                                <asp:Label ID="CreateUserLabel" runat="server" Text='<%# Bind("FullName") %>' CssClass="comment" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadForwarderLabel" runat="server" Text="Forwarder:" meta:resourcekey="DHeadForwarderLabelResource1" /></td>
                            <td><asp:DropDownList ID="ForwarderDropDownList" runat="server" DataSourceID="SqlDataSource_Forwarders" CssClass="grey"
                                    DataTextField="Name" DataValueField="ForwarderID" SelectedValue='<%# Bind("ForwarderID") %>' >
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource_Forwarders" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                    SelectCommand="SELECT ForwarderID, Name FROM Delivery.Forwarder ORDER BY Name">
                                </asp:SqlDataSource>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadT1Label" runat="server" Text="T1 Number:" meta:resourcekey="DHeadT1LabelResource1" /></td>
                            <td><asp:TextBox ID="T1NumberTextBox" runat="server" Text='<%# Bind("T1Number") %>' CssClass="grey" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadTruckRegLabel" runat="server" Text="Truck Registration Number:" meta:resourcekey="DHeadTruckRegLabelResource1" /></td>
                            <td><asp:TextBox ID="TruckRegistrationNumberTextBox" runat="server" Text='<%# Bind("TruckRegistrationNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorTruckReg" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="TruckRegistrationNumberTextBox" ValidationGroup="UpdateGateReg" CssClass="red" 
                                    meta:resourcekey="ReqFieldValidatorTruckRegResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadTotalPackageCountLabel" runat="server" Text="Total Number of Packages:" meta:resourcekey="DHeadTotalPackageCountLabelResource1" /></td>
                            <td><asp:Label ID="TotalPackageCountLabel" runat="server" Text='<%# Bind("TotalPackageCount") %>' />
                            </td>
                        </tr>
                        <tr><td></td>
                            <td><asp:Button ID="GRUpdateButton" runat="server" CommandName="Update" Text="Update" 
                                    ValidationGroup="UpdateGateReg" meta:resourcekey="GRUpdateButtonResource1" />
                            </td>
                        </tr>
                    </table>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <h3><asp:Label ID="CreateNewGateRegLabel" runat="server" Text="Create a new Gate Registration:" meta:resourcekey="CreateNewGateRegLabelResource1" /></h3>
                    <table style="width: 100%;">
                        <tr><td><asp:Label ID="DHeadForwarderLabel" runat="server" Text="Forwarder:" meta:resourcekey="DHeadForwarderLabelResource1" /></td>
                            <td><asp:DropDownList ID="ForwarderDropDownList" runat="server" DataSourceID="SqlDataSource_Forwarders" CssClass="grey"
                                    DataTextField="Name" DataValueField="ForwarderID" SelectedValue='<%# Bind("ForwarderID") %>' >
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource_Forwarders" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                    SelectCommand="SELECT ForwarderID, Name FROM Delivery.Forwarder ORDER BY Name">
                                </asp:SqlDataSource>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadT1Label" runat="server" Text="T1 Number:" meta:resourcekey="DHeadT1LabelResource1" /></td>
                            <td><asp:TextBox ID="T1NumberTextBox" runat="server" Text='<%# Bind("T1Number") %>' CssClass="grey" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DHeadTruckRegLabel" runat="server" Text="Truck Registration Number:" meta:resourcekey="DHeadTruckRegLabelResource1" /></td>
                            <td><asp:TextBox ID="TruckRegistrationNumberTextBox" runat="server" Text='<%# Bind("TruckRegistrationNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorTruckReg" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="TruckRegistrationNumberTextBox" ValidationGroup="InsertGateReg" CssClass="red" 
                                    meta:resourcekey="ReqFieldValidatorTruckRegResource1" />
                            </td>
                        </tr>
                        <tr><td></td>
                            <td><asp:Button ID="NewGRInsertButton" runat="server" CommandName="Insert" Text="Create" 
                                    ValidationGroup="InsertGateReg" meta:resourcekey="NewGRInsertButtonResource1" />
                                &nbsp;
                                <asp:Button ID="InsertCancelButton" runat="server" CommandName="Cancel" Text="Cancel" meta:resourcekey="InsertCancelButtonResource1" />
                            </td>
                        </tr>
                    </table>
                </InsertItemTemplate>
            </asp:FormView>

            <asp:SqlDataSource ID="SqlDataSource_FormViewDeliveryHeader" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT DeliveryID, CreateDate, h.ForwarderID, f.Name, T1Number, TruckRegistrationNumber, TotalPackageCount, u.FullName
                    FROM Delivery.DeliveryHeader h
                        LEFT JOIN Delivery.Forwarder f ON f.ForwarderID = h.ForwarderID
                        LEFT JOIN Usr.[User] u ON h.CreateUserID = u.UserID
                    WHERE (DeliveryID = @DeliveryID)" 
                UpdateCommand="UPDATE Delivery.DeliveryHeader SET TruckRegistrationNumber = @TruckRegistrationNumber, T1Number = @T1Number, ForwarderID = @ForwarderID, LastUpdateDate = GETDATE(), LastUpdateUserID = @UserId WHERE (DeliveryID = @DeliveryID)"
                InsertCommand="INSERT INTO Delivery.DeliveryHeader(TruckRegistrationNumber, T1Number, ForwarderID, CreateUserID) VALUES (@TruckRegistrationNumber, @T1Number, @ForwarderID, @UserId);
                                SELECT @DeliveryID = SCOPE_IDENTITY()"
                OnInserted="SqlDataSource_FormViewDeliveryHeader_Inserted">
                <SelectParameters>
                    <asp:ControlParameter Name="DeliveryID" ControlID="ListBox1" PropertyName="SelectedValue" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="ForwarderID" />
                    <asp:Parameter Name="T1Number" />
                    <asp:Parameter Name="TruckRegistrationNumber" />
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:Parameter Name="DeliveryID" />
                </UpdateParameters>
                <InsertParameters>
                    <asp:Parameter Name="TruckRegistrationNumber" />
                    <asp:Parameter Name="T1Number" />
                    <asp:Parameter Name="ForwarderID" />
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:Parameter Name="DeliveryID" Direction="Output" Type="Int32" />
                </InsertParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource_DeliveryHeader_TotalPackageCount" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                UpdateCommand="UPDATE Delivery.DeliveryHeader SET TotalPackageCount = (SELECT SUM(PackageCount1) AS Expr1 FROM Delivery.DeliveryLine WHERE (DeliveryID = @DeliveryID)) WHERE (DeliveryID = @DeliveryID)">
                <UpdateParameters>
                    <asp:ControlParameter Name="DeliveryID" ControlID="ListBox1" PropertyName="SelectedValue" />
                </UpdateParameters>
            </asp:SqlDataSource>

            <br />

            <asp:GridView ID="GridViewDeliveryLines" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" 
                DataSourceID="SqlDataSource_DeliveryLines" DataKeyNames="DeliveryLineID" GridLines="None" EnablePersistedSelection="True" 
                OnSelectedIndexChanged="GridViewDeliveryLines_SelectedIndexChanged" OnRowDataBound="GridViewDeliveryLines_RowDataBound">
                <AlternatingRowStyle BackColor="White" />
                <Columns>
                    <asp:BoundField DataField="DeliveryLineID" HeaderText="Line ID" meta:resourcekey="DLinesGVLineIDResource1" />
                    <asp:TemplateField HeaderText="Freight Bill" meta:resourcekey="DLinesGVFreightBillResource1">
                        <ItemTemplate><asp:Label ID="FreightBillNumberLabel" runat="server" Text='<%# HighlightFB(Eval("FreightBillNumber").ToString()) %>' /></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Name" HeaderText="Supplier" meta:resourcekey="DLinesGVSupplierResource1" />
                    <asp:BoundField DataField="CountryOfDispatch" HeaderText="Dispatch" meta:resourcekey="DLinesGVDispatchResource1" />
                    <asp:BoundField DataField="GrossWeight" HeaderText="Gross Weight" meta:resourcekey="DLinesGVGrossWeightResource1" />
                    <asp:BoundField DataField="PackageCount1" HeaderText="Packages" meta:resourcekey="DLinesGVPackagesResource1" />
                    <asp:BoundField DataField="AK" HeaderText="AK" />
                    <asp:BoundField DataField="TERM" HeaderText="TERM" />
                    <asp:BoundField DataField="Comment" HeaderText="Comment" meta:resourcekey="DLinesGVCommentResource1" />
                    <asp:BoundField DataField="Attachments" HeaderText="Attachments" meta:resourcekey="DLinesGVAttachmentsResource1" />
                    <asp:BoundField DataField="Urgent" HeaderText="Info" ControlStyle-Font-Bold="true"><ItemStyle Font-Bold="true" /></asp:BoundField>
                </Columns>
                <EditRowStyle BackColor="#2461BF" />
                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                <RowStyle BackColor="#EFF3FB" />
                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
            </asp:GridView>

            <asp:SqlDataSource ID="SqlDataSource_DeliveryLines" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT d.DeliveryLineID, d.DeliveryID, d.SupplierID, s.Name, d.CountryOfDispatch, d.FreightBillNumber, d.GrossWeight, d.PackageCount1, 
                        AK = CASE d.IsAccountingEntry WHEN 1 THEN 'AK' ELSE '' END, TERM = CASE d.IsTerm WHEN 1 THEN 'TERM' ELSE '' END,
                        d.Comment, count(a.AttachmentID) Attachments, CASE n.IsUrgent WHEN 1 THEN 'URGENT!' ELSE '' END as Urgent
                    FROM Delivery.DeliveryLine AS d 
                    INNER JOIN Delivery.Supplier AS s ON d.SupplierID = s.SupplierID 
                    LEFT JOIN Delivery.Attachment AS a ON d.DeliveryLineID = a.DeliveryLineID 
                    LEFT JOIN Delivery.Notify AS n ON d.FreightBillNumber = n.FreightBillNumber
                    WHERE d.DeliveryID = @DeliveryID
                    GROUP BY d.DeliveryLineID, d.DeliveryID, d.SupplierID, s.Name, d.CountryOfDispatch, d.FreightBillNumber, d.GrossWeight, d.PackageCount1, d.IsAccountingEntry, d.IsTerm, d.Comment, n.IsUrgent">
                <SelectParameters>
                    <asp:ControlParameter Name="DeliveryID" ControlID="ListBox1" PropertyName="SelectedValue" />
                </SelectParameters>
            </asp:SqlDataSource>


            <asp:Button ID="BtnNewDeliveryLine" runat="server" Text="Create a New Delivery Line" Visible="False" 
                OnClick="BtnNewDeliveryLine_Click" meta:resourcekey="BtnNewDeliveryLineResource1" />

            <asp:FormView ID="FormViewDeliveryLine" runat="server" DefaultMode="Edit" DataSourceID="SqlDataSource_DeliveryLine" DataKeyNames="DeliveryLineID" 
                OnItemInserted="FormViewDeliveryLine_ItemInserted" OnItemUpdated="FormViewDeliveryLine_ItemUpdated" OnDataBound="FormViewDeliveryLine_DataBound">
                <EditItemTemplate>
                    <br />
                    <table style="width: 100%;">
                        <tr><td><asp:Label ID="DLineFVLineIDEditLabel" runat="server" Text="Edit Delivery line:" Font-Bold="True" meta:resourcekey="DLineFVLineIDEditLabelResource1" /></td>
                            <td>
                                <asp:Label ID="DeliveryLineIDLabel" runat="server" Text='<%# Bind("DeliveryLineID") %>' Font-Bold="True" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVFreightBillLabel" runat="server" Text="Freight Bill Number:" meta:resourcekey="DLineFVFreightBillLabelResource1" /></td>
                            <td>
                                <asp:TextBox ID="FreightBillNumberTextBox" runat="server" Text='<%# Bind("FreightBillNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorFreightBillNumber" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="FreightBillNumberTextBox" ValidationGroup="EditDeliveryLine" CssClass="red" Display="Dynamic" 
                                    meta:resourcekey="ReqFieldValidatorFreightBillNumberResource1" />
                                <asp:Label ID="UrgentFBLabel" runat="server" Text='<%# Bind("Urgent") %>' CssClass="red" />
                                <asp:Label ID="NotifyCommentLabel" runat="server" Text='<%# Bind("NotifyComment") %>' CssClass="red" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVSupplierLabel" runat="server" Text="Supplier:" meta:resourcekey="DLineFVSupplierLabelResource1" /></td>
                            <td>
                                <asp:DropDownList ID="SupplierDropDownList" runat="server" DataSourceID="SqlDataSource_Suppliers" CssClass="grey"
                                    DataTextField="Name" DataValueField="SupplierID" SelectedValue='<%# Bind("SupplierID") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorSupplier" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="SupplierDropDownList" ValidationGroup="EditDeliveryLine" CssClass="red"  Display="Dynamic" 
                                    meta:resourcekey="ReqFieldValidatorSupplierResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVDispatchLabel" runat="server" Text="Country Of Dispatch:" meta:resourcekey="DLineFVDispatchLabelResource1" /></td>
                            <td>
                                <asp:DropDownList ID="CountryOfDispatchDropDownList" runat="server" DataSourceID="SqlDataSource_Countries" CssClass="grey"
                                    DataTextField="NameAndCode" DataValueField="Name" SelectedValue='<%# Bind("CountryOfDispatch") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVIncotermLabel" runat="server" Text="Incoterm:" meta:resourcekey="DLineFVIncotermLabelResource1" /></td>
                            <td>
                                <asp:DropDownList ID="IncotermDropDownList" runat="server" DataSourceID="SqlDataSource_Incoterms" CssClass="grey"
                                    DataTextField="IncotermCode" DataValueField="IncotermCode" SelectedValue='<%# Bind("Incoterm") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVGrossWeightLabel" runat="server" Text="Gross Weight:" meta:resourcekey="DLineFVGrossWeightLabelResource1" /></td>
                            <td>
                                <asp:TextBox ID="GrossWeightTextBox" runat="server" Text='<%# Bind("GrossWeight") %>' CssClass="grey" />
                                <asp:RegularExpressionValidator ID="RegExValidatorGrossWeight" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="GrossWeightTextBox" ValidationGroup="EditDeliveryLine" 
                                    CssClass="red" Display="Dynamic" ValidationExpression="^\d+([,.]\d+)?$" 
                                    meta:resourcekey="RegExValidatorGrossWeightResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageCountLabel" runat="server" Text="Number of Packages (Type 1):" meta:resourcekey="DLineFVPackageCountLabelResource1" /></td>
                            <td>
                                <asp:TextBox ID="PackageCountTextBox" runat="server" Text='<%# Bind("PackageCount1") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorPackages1" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="PackageCountTextBox" ValidationGroup="EditDeliveryLine" 
                                    CssClass="red" Display="Dynamic" meta:resourcekey="ReqFieldValidatorPackagesResource1" />
                                <asp:RegularExpressionValidator ID="RegExValidatorPackages1" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="PackageCountTextBox" ValidationGroup="EditDeliveryLine" 
                                    CssClass="red" Display="Dynamic" ValidationExpression="^\d+$" meta:resourcekey="RegExValidatorPackagesResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageTypeLabel1" runat="server" Text="Type 1 of Package:" meta:resourcekey="DLineFVPackageTypeLabelResource1" /></td>
                            <td>
                                <asp:DropDownList ID="PackageTypeDropDownList1" runat="server" DataSourceID="SqlDataSource_PackageTypes1" CssClass="grey"
                                    DataTextField="Description" DataValueField="PackageType1" SelectedValue='<%# Bind("PackageType1") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageCountLabel2" runat="server" Text="Number of Packages (Type2):" meta:resourcekey="DLineFVPackageCountLabelResource2" /></td>
                            <td><asp:TextBox ID="PackageCountTextBox2" runat="server" Text='<%# Bind("PackageCount2") %>' CssClass="grey" />
                                <asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="PackageCountTextBox2" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    ValidationExpression="^\d+$" meta:resourcekey="RegExValidatorPackagesResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageTypeLabel2" runat="server" Text="Type 2 of Package:" meta:resourcekey="DLineFVPackageTypeLabelResource2" /></td>
                            <td>
                                <asp:DropDownList ID="PackageTypeDropDownList2" runat="server" DataSourceID="SqlDataSource_PackageTypes2" CssClass="grey"
                                    DataTextField="Description" DataValueField="PackageType2" SelectedValue='<%# Bind("PackageType2") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr> 
                        <tr><td><asp:Label ID="DLineFVPackageCountLabel3" runat="server" Text="Number of Packages (Type3):" meta:resourcekey="DLineFVPackageCountLabelResource3" /></td>
                            <td><asp:TextBox ID="PackageCountTextBox3" runat="server" Text='<%# Bind("PackageCount3") %>' CssClass="grey" />
                                <asp:RegularExpressionValidator ID="RegularExpressionValidator3" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="PackageCountTextBox3" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    ValidationExpression="^\d+$" meta:resourcekey="RegExValidatorPackagesResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageTypeLabel3" runat="server" Text="Type 3 of Package:" meta:resourcekey="DLineFVPackageTypeLabelResource3" /></td>
                            <td>
                                <asp:DropDownList ID="PackageTypeDropDownList3" runat="server" DataSourceID="SqlDataSource_PackageTypes3" CssClass="grey"
                                    DataTextField="Description" DataValueField="PackageType3" SelectedValue='<%# Bind("PackageType3") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>                         
                        <tr><td><asp:Label ID="DLineFVAccountingEntryLabel" runat="server" Text="AK:" meta:resourcekey="DLineFVAccountingEntryLabelResource1" /></td>
                            <td>
                                <asp:CheckBox ID="AccountingEntryCheckBox" runat="server" Checked='<%# Bind("IsAccountingEntry") %>' />
                                <asp:Label ID="AccountingEntryInfoLabel" runat="server" Visible="false" CssClass="comment">AK allowed only with T1</asp:Label>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVTermLabel" runat="server" Text="TERM:" meta:resourcekey="DLineFVTermLabelResource1" /></td>
                            <td>
                                <asp:CheckBox ID="TermCheckBox" runat="server" Checked='<%# Bind("IsTerm") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVCustomsClearedLabel" runat="server" Text="Customs Cleared:" meta:resourcekey="DLineFVCustomsClearedLabelResource1" /></td>
                            <td>
                                <asp:CheckBox ID="CustomsClearedCheckBox" runat="server" Checked='<%# Bind("IsCustomsCleared") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVContactLabel" runat="server" Text="Named Delivery:" meta:resourcekey="DLineFVContactLabelResource1" /></td>
                            <td><asp:DropDownList ID="ContactDropDownList" runat="server" DataSourceID="SqlDataSource_Contacts" CssClass="grey"
                                    DataTextField="FullName" DataValueField="ContactID" SelectedValue='<%# Bind("ContactID") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVCommentLabel" runat="server" Text="Comment:" meta:resourcekey="DLineFVCommentLabelResource1" /></td>
                            <td><asp:TextBox ID="CommentTextBox" runat="server" Text='<%# Bind("Comment") %>' CssClass="grey" />
                            </td>
                        </tr>
                        <tr><td valign="top"><asp:Label ID="DLineFVAttachmentsLabel" runat="server" Text="Attachments:" meta:resourcekey="DLineFVAttachmentsLabelResource1" /></td>
                            <td>
                                <asp:GridView ID="GridViewAttachments" runat="server" GridLines="None"
                                    DataSourceID="SqlDataSource_Attachments" AutoGenerateColumns="False" DataKeyNames="AttachmentID,Path,FileName"
                                    BorderStyle="None" ShowHeader="False" OnSelectedIndexChanged="GridViewAttachments_SelectedIndexChanged">
                                    <Columns>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <a href='<%# Eval("Path").ToString() + Eval("FileName").ToString() %>' target="_blank">
                                                    <img src="Images/file-icon.jpg" style="vertical-align:middle;" alt="" /><%# Eval("FileName").ToString() %>
                                                </a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="CreateDate" DataFormatString="{0:g}" ItemStyle-Font-Size="Smaller" />
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:LinkButton ID="AttachmentDeleteButton" runat="server" CommandName="select" Text="X"
                                                    OnClientClick="if (!window.confirm('Remove attachment from this line?')) return false;" 
                                                    Font-Bold="True" Font-Underline="False" ForeColor="Red" meta:resourcekey="DLineFVAttachmentDeleteButtonResource1" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <a title="Add Attachment" onclick="ShowHide('attach'); return false;" href="#">
                                    <asp:Label ID="AddAttachmentLabel" runat="server" Text="Add &gt;&gt;" meta:resourcekey="DLineFVAttachmentAddLabelResource1" />
                                </a>
                                <div id="attach" class="hidden">
                                    <asp:GridView runat="server" id="GridViewIncAttachments" AutoGenerateColumns="False" DataKeyNames="Name" 
                                        BackColor="Gray" BorderColor="#999999" BorderStyle="Solid" BorderWidth="2px" CellPadding="4" ForeColor="Black" 
                                        OnSelectedIndexChanged="GridViewIncAttachments_SelectedIndexChanged" meta:resourcekey="GridViewIncAttachmentsResource1">
                                        <Columns>
                                            <asp:CommandField ButtonType="Button" SelectText="Add" ShowSelectButton="True" meta:resourcekey="GridViewIncAttachmentsCommandFieldResource1" />
                                            <asp:TemplateField HeaderText="File Name" meta:resourcekey="GridViewIncAttachmentsFilenameResource1">
                                                <ItemTemplate>
                                                    <a href='<%# Eval("FullName").ToString() %>' target="_blank">
                                                        <img src="Images/file-icon.jpg" style="vertical-align:middle;" alt="" /><%# Eval("Name").ToString() %>
                                                    </a>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="LastWriteTime" HeaderText="Created" DataFormatString="{0:d}" meta:resourcekey="GridViewIncAttachmentsCreatedResource1" />
                                            <asp:BoundField DataField="Length" HeaderText="File Size" DataFormatString="{0:#,### bytes}" meta:resourcekey="GridViewIncAttachmentsFilesizeResource1" />
                                        </Columns>
                                        <HeaderStyle BackColor="#FFCC99" Font-Bold="True" ForeColor="#666633" />
                                        <PagerStyle BackColor="#CCCCCC" ForeColor="Black" HorizontalAlign="Left" />
                                        <RowStyle BackColor="White" />
                                        <EmptyDataRowStyle BackColor="#FFCC99" />
                                    </asp:GridView>
                                </div>
                            </td>
                        </tr>
                        <tr><td></td>
                            <td><br />
                                <asp:Button ID="DeliveryLineUpdateButton" runat="server" ValidationGroup="EditDeliveryLine" 
                                    CommandName="Update" Text="Update" meta:resourcekey="DeliveryLineUpdateButtonResource1" />
                                &nbsp;
                                <asp:Button ID="DeliveryLineUpdateCancelButton" runat="server" CausesValidation="False" OnClick="DeliveryLineCancelButtons_Click" 
                                    CommandName="Cancel" Text="Cancel" meta:resourcekey="DeliveryLineUpdateCancelButtonResource1" />
                            </td>
                        </tr>
                    </table>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <br />
                    <table style="width: 100%;">
                        <tr><td colspan="2"><asp:Label ID="DLineFVLineIDInsertLabel" runat="server" Text="Create a new Delivery Line:" Font-Bold="True" meta:resourcekey="DLineFVLineIDInsertLabelResource1" /></td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVFreightBillLabel" runat="server" Text="Freight Bill Number:" meta:resourcekey="DLineFVFreightBillLabelResource1" /></td>
                            <td><asp:TextBox ID="FreightBillNumberTextBox" runat="server" Text='<%# Bind("FreightBillNumber") %>' CssClass="grey"  />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorFreightBillNumber" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="FreightBillNumberTextBox" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    meta:resourcekey="ReqFieldValidatorFreightBillNumberResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVSupplierLabel" runat="server" Text="Supplier:" meta:resourcekey="DLineFVSupplierLabelResource1" /></td>
                            <td><asp:DropDownList ID="SupplierDropDownList" runat="server" DataSourceID="SqlDataSource_Suppliers" CssClass="grey"
                                    DataTextField="Name" DataValueField="SupplierID" SelectedValue='<%# Bind("SupplierID") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorSupplier" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="SupplierDropDownList" ValidationGroup="InsertDeliveryLine" CssClass="red" 
                                    meta:resourcekey="ReqFieldValidatorSupplierResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVDispatchLabel" runat="server" Text="Country Of Dispatch:" meta:resourcekey="DLineFVDispatchLabelResource1" /></td>
                            <td><asp:DropDownList ID="CountryOfDispatchDropDownList" runat="server" DataSourceID="SqlDataSource_Countries" CssClass="grey"
                                    DataTextField="NameAndCode" DataValueField="Name" SelectedValue='<%# Bind("CountryOfDispatch") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVIncotermLabel" runat="server" Text="Incoterm" meta:resourcekey="DLineFVIncotermLabelResource1" /></td>
                            <td><asp:DropDownList ID="IncotermDropDownList" runat="server" DataSourceID="SqlDataSource_Incoterms" CssClass="grey"
                                    DataTextField="IncotermCode" DataValueField="IncotermCode" SelectedValue='<%# Bind("Incoterm") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVGrossWeightLabel" runat="server" Text="Gross Weight:" meta:resourcekey="DLineFVGrossWeightLabelResource1" /></td>
                            <td><asp:TextBox ID="GrossWeightTextBox" runat="server" Text='<%# Bind("GrossWeight") %>' CssClass="grey" />
                                <asp:RegularExpressionValidator ID="RegExValidatorGrossWeight" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="GrossWeightTextBox" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    ValidationExpression="^\d+([,.]\d+)?$" meta:resourcekey="RegExValidatorGrossWeightResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageCountLabel1" runat="server" Text="Number of Packages (Type1):" meta:resourcekey="DLineFVPackageCountLabelResource1" /></td>
                            <td><asp:TextBox ID="PackageCountTextBox" runat="server" Text='<%# Bind("PackageCount1") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorPackages1" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="PackageCountTextBox" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    meta:resourcekey="ReqFieldValidatorPackagesResource1" />
                                <asp:RegularExpressionValidator ID="RegExValidatorPackages1" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="PackageCountTextBox" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    ValidationExpression="^\d+$" meta:resourcekey="RegExValidatorPackagesResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageTypeLabel1" runat="server" Text="Type 1 of Package:" meta:resourcekey="DLineFVPackageTypeLabelResource1" /></td>
                            <td>
                                <asp:DropDownList ID="PackageTypeDropDownList1" runat="server" DataSourceID="SqlDataSource_PackageTypes1" CssClass="grey"
                                    DataTextField="Description" DataValueField="PackageType1" SelectedValue='<%# Bind("PackageType1") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageCountLabel2" runat="server" Text="Number of Packages (Type2):" meta:resourcekey="DLineFVPackageCountLabelResource2" /></td>
                            <td><asp:TextBox ID="PackageCountTextBox2" runat="server" Text='<%# Bind("PackageCount2") %>' CssClass="grey" />
                                <asp:RegularExpressionValidator ID="RegExValidatorPackages2" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="PackageCountTextBox2" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    ValidationExpression="^\d+$" meta:resourcekey="RegExValidatorPackagesResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageTypeLabel2" runat="server" Text="Type 2 of Package:" meta:resourcekey="DLineFVPackageTypeLabelResource2" /></td>
                            <td>
                                <asp:DropDownList ID="PackageTypeDropDownList2" runat="server" DataSourceID="SqlDataSource_PackageTypes2" CssClass="grey"
                                    DataTextField="Description" DataValueField="PackageType2" SelectedValue='<%# Bind("PackageType2") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr> 
                        <tr><td><asp:Label ID="DLineFVPackageCountLabel3" runat="server" Text="Number of Packages (Type3):" meta:resourcekey="DLineFVPackageCountLabelResource3" /></td>
                            <td><asp:TextBox ID="PackageCountTextBox3" runat="server" Text='<%# Bind("PackageCount3") %>' CssClass="grey" />
                                <asp:RegularExpressionValidator ID="RegularExpressionValidator3" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="PackageCountTextBox3" ValidationGroup="InsertDeliveryLine" CssClass="red" Display="Dynamic" 
                                    ValidationExpression="^\d+$" meta:resourcekey="RegExValidatorPackagesResource1" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVPackageTypeLabel3" runat="server" Text="Type 3 of Package:" meta:resourcekey="DLineFVPackageTypeLabelResource3" /></td>
                            <td>
                                <asp:DropDownList ID="PackageTypeDropDownList3" runat="server" DataSourceID="SqlDataSource_PackageTypes3" CssClass="grey"
                                    DataTextField="Description" DataValueField="PackageType3" SelectedValue='<%# Bind("PackageType3") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr> 
                        <tr><td><asp:Label ID="DLineFVAccountingEntryLabel" runat="server" Text="AK:" meta:resourcekey="DLineFVAccountingEntryLabelResource1" /></td>
                            <td><asp:CheckBox ID="AccountingEntryCheckBox" runat="server" Checked='<%# Bind("IsAccountingEntry") %>' /></td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVTermLabel" runat="server" Text="AK:" meta:resourcekey="DLineFVTermLabelResource1" /></td>
                            <td><asp:CheckBox ID="TermCheckBox" runat="server" Checked='<%# Bind("IsTerm") %>' /></td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVCustomsClearedLabel" runat="server" Text="AK:" meta:resourcekey="DLineFVCustomsClearedLabelResource1" /></td>
                            <td><asp:CheckBox ID="CustomsClearedCheckBox" runat="server" Checked='<%# Bind("IsCustomsCleared") %>' /></td>
                        </tr>                        
                        <tr><td><asp:Label ID="DLineFVContactLabel" runat="server" Text="Named Delivery:" meta:resourcekey="DLineFVContactLabelResource1" /></td>
                            <td><asp:DropDownList ID="ContactDropDownList" runat="server" DataSourceID="SqlDataSource_Contacts" CssClass="grey"
                                    DataTextField="FullName" DataValueField="ContactID" SelectedValue='<%# Bind("ContactID") %>' AppendDataBoundItems="True">
                                    <asp:ListItem Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="DLineFVCommentLabel" runat="server" Text="Comment:" meta:resourcekey="DLineFVCommentLabelResource1" /></td>
                            <td><asp:TextBox ID="CommentTextBox" runat="server" Text='<%# Bind("Comment") %>' CssClass="grey" /></td>
                        </tr>
                        <tr><td></td>
                            <td><asp:Button ID="DeliveryLineInsertButton" runat="server" ValidationGroup="InsertDeliveryLine" 
                                    CommandName="Insert" Text="Insert New Line" OnClick="DeliveryLineInsertButton_Click" 
                                    meta:resourcekey="DeliveryLineInsertButtonResource1" />
                                &nbsp;
                                <asp:Button ID="DeliveryLineInsertCancelButton" runat="server" CausesValidation="False"
                                    CommandName="Cancel" Text="Cancel" OnClick="DeliveryLineCancelButtons_Click" 
                                    meta:resourcekey="DeliveryLineInsertCancelButtonResource1" />
                            </td>
                        </tr>
                    </table>
                </InsertItemTemplate>
            </asp:FormView>

            <asp:SqlDataSource ID="SqlDataSource_DeliveryLine" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT d.DeliveryLineID, d.SupplierID, d.FreightBillNumber, d.GrossWeight, d.CountryOfDispatch, d.Incoterm, d.PackageCount1, d.PackageCount2, d.PackageCount3, d.PackageType1, d.PackageType2, d.PackageType3, d.IsAccountingEntry, d.IsTerm, d.IsCustomsCleared, d.Comment, d.ContactID
                        , CASE n.IsUrgent WHEN 1 THEN '[URGENT]' ELSE '' END as Urgent, n.Comment NotifyComment
                    FROM Delivery.DeliveryLine AS d
                    LEFT JOIN Delivery.Notify AS n ON d.FreightBillNumber = n.FreightBillNumber
                    WHERE d.DeliveryLineID = @DeliveryLineID" 
                UpdateCommand="UPDATE Delivery.DeliveryLine SET SupplierID = @SupplierID, FreightBillNumber = @FreightBillNumber, 
                        GrossWeight=REPLACE(@GrossWeight, ',', '.'), CountryOfDispatch = @CountryOfDispatch, Incoterm = @Incoterm, 
                        PackageCount1 = @PackageCount1, PackageCount2 = @PackageCount2, PackageCount3 = @PackageCount3, IsAccountingEntry = @IsAccountingEntry, IsTerm = @IsTerm, IsCustomsCleared = @IsCustomsCleared, Comment = @Comment,
                        LastUpdateDate = GETDATE(), LastUpdateUserID = @UserId, ContactID = @ContactID, PackageType1 = @PackageType1, PackageType2 = @PackageType2, PackageType3 = @PackageType3
                    WHERE DeliveryLineID = @DeliveryLineID"
                InsertCommand="INSERT INTO Delivery.DeliveryLine (DeliveryID, SupplierID, FreightBillNumber, GrossWeight, CountryOfDispatch, Incoterm, PackageCount1, PackageCount2, PackageCount3, PackageType1, PackageType2, PackageType3, IsAccountingEntry, IsTerm, IsCustomsCleared, Comment, CreateUserID, ContactID) 
                    VALUES (@DeliveryID, @SupplierID, @FreightBillNumber, REPLACE(@GrossWeight, ',', '.'), @CountryOfDispatch, @Incoterm, @PackageCount1, @PackageCount2, @PackageCount3, @PackageType1, @PackageType2, @PackageType3, @IsAccountingEntry, @IsTerm, @IsCustomsCleared, @Comment, @UserId, @ContactID)">
                <SelectParameters>
                    <asp:ControlParameter Name="DeliveryLineID" ControlID="GridViewDeliveryLines" PropertyName="SelectedValue" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="SupplierID" />
                    <asp:Parameter Name="FreightBillNumber" />
                    <asp:Parameter Name="GrossWeight" />
                    <asp:Parameter Name="CountryOfDispatch" />
                    <asp:Parameter Name="Incoterm" />
                    <asp:Parameter Name="PackageCount1" />
                    <asp:Parameter Name="PackageCount2" />
                    <asp:Parameter Name="PackageCount3" />
                    <asp:Parameter Name="PackageType1" />
                    <asp:Parameter Name="PackageType2" />
                    <asp:Parameter Name="PackageType3" />
                    <asp:Parameter Name="Comment" />
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:Parameter Name="ContactID" />
                    <asp:Parameter Name="DeliveryLineID" />
                </UpdateParameters>
                <%-- Note! No need to specify checkboxes as parameters. They still work with Update and Insert. --%>
                <InsertParameters>
                    <asp:Parameter Name="DeliveryID" />
                    <asp:Parameter Name="SupplierID" />
                    <asp:Parameter Name="FreightBillNumber" />
                    <asp:Parameter Name="GrossWeight" />
                    <asp:Parameter Name="CountryOfDispatch" />
                    <asp:Parameter Name="Incoterm" />
                    <asp:Parameter Name="PackageCount1" />
                    <asp:Parameter Name="PackageCount2" />
                    <asp:Parameter Name="PackageCount3" />
                    <asp:Parameter Name="PackageType1" />
                    <asp:Parameter Name="PackageType2" />
                    <asp:Parameter Name="PackageType3" />
                    <asp:Parameter Name="Comment" />
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:Parameter Name="ContactID" />
                </InsertParameters>
            </asp:SqlDataSource>

            <%-- Datasource used by code behind SendFBNotifyEmails() functions --%>
            <asp:SqlDataSource ID="SqlDataSource_DeliveryLineNotify" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT TOP 1 d.DeliveryID, d.DeliveryLineID, n.DeliveryLineID NotifyDeliveryLineID, s.Name SupplierName, d.FreightBillNumber, d.GrossWeight, d.CountryOfDispatch, d.Incoterm, d.PackageCount1, d.IsAccountingEntry, d.IsTerm, d.IsCustomsCleared, d.Comment 
                        , CASE n.IsUrgent WHEN 1 THEN 'YES' ELSE 'No' END as Urgent, n.Comment NotifyComment
                    FROM Delivery.DeliveryLine AS d
                    INNER JOIN Delivery.Supplier AS s ON d.SupplierID = s.SupplierID
                    INNER JOIN Delivery.Notify AS n ON d.FreightBillNumber = n.FreightBillNumber
                    WHERE n.FreightBillNumber = @FreightBillNumber
                    ORDER BY d.DeliveryLineID DESC" 
                UpdateCommand="UPDATE Delivery.Notify SET DeliveryLineID = @DeliveryLineID WHERE FreightBillNumber = @FreightBillNumber">
                <SelectParameters>
                    <asp:Parameter Name="FreightBillNumber" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="DeliveryLineID" />
                    <asp:Parameter Name="FreightBillNumber" />
                </UpdateParameters>
            </asp:SqlDataSource>

            <%-- Datasource used by code behind SendFBNotifyEmails() function --%>
            <asp:SqlDataSource ID="SqlDataSource_DeliveryLineNotifyEmails" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT n.NotifyID, c.ContactID, c.FullName, c.Email
                    FROM Delivery.Notify n
                    INNER JOIN Delivery.NotifyContacts nc ON n.NotifyID = nc.NotifyID AND nc.IsSent = 0
                    INNER JOIN Usr.Contacts c ON nc.ContactID = c.ContactID
                    WHERE n.FreightBillNumber = @FreightBillNumber" 
                UpdateCommand="UPDATE Delivery.NotifyContacts SET IsSent = 1 WHERE NotifyID = @NotifyID AND ContactID = @ContactID">
                <SelectParameters>
                    <asp:Parameter Name="FreightBillNumber" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="NotifyID" />
                    <asp:Parameter Name="ContactID" />
                </UpdateParameters>
            </asp:SqlDataSource>

            <%-- Datasource used by code behind SendFBNamedDeliveryEmails() function --%>
            <asp:SqlDataSource ID="SqlDataSource_DeliveryLineNamed" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT TOP 1 d.DeliveryID, d.DeliveryLineID, s.Name SupplierName, d.FreightBillNumber, d.GrossWeight, d.CountryOfDispatch, d.IsTerm, d.IsCustomsCleared, d.Comment 
                        , d.ContactID, c.FullName as ContactName, c.Email 
                    FROM Delivery.DeliveryLine AS d
                    LEFT JOIN Delivery.Supplier AS s ON d.SupplierID = s.SupplierID
                    LEFT JOIN Usr.Contacts      AS c ON d.ContactID = c.ContactID
                    WHERE d.FreightBillNumber = @FreightBillNumber
                    ORDER BY d.DeliveryLineID DESC">
                <SelectParameters>
                    <asp:Parameter Name="FreightBillNumber" />
                </SelectParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource_Suppliers" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT SupplierID, Name FROM Delivery.Supplier ORDER BY Name">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_Countries" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT Name, Name + ' (' + Code + ')' AS NameAndCode FROM Delivery.Country ORDER BY Name">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_Incoterms" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>"
                SelectCommand="SELECT IncotermCode FROM Delivery.IncotermCode ORDER BY IncotermCode">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_PackageTypes1" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT PackageType AS PackageType1,PackageType AS Description FROM Delivery.PackageType1 ORDER BY PackageType1">
            </asp:SqlDataSource>  
            <asp:SqlDataSource ID="SqlDataSource_PackageTypes2" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT PackageType AS PackageType2,PackageType AS Description FROM Delivery.PackageType2 ORDER BY PackageType2">
            </asp:SqlDataSource> 
            <asp:SqlDataSource ID="SqlDataSource_PackageTypes3" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT PackageType AS PackageType3,PackageType AS Description FROM Delivery.PackageType3 ORDER BY PackageType3">
            </asp:SqlDataSource>           
            <asp:SqlDataSource ID="SqlDataSource_Contacts" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT ContactID, FullName FROM Usr.Contacts ORDER BY FullName">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_Attachments" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT AttachmentID, Path, FileName, CreateDate FROM Delivery.Attachment WHERE (DeliveryLineID = @DeliveryLineID)"
                InsertCommand="INSERT INTO Delivery.Attachment(Path, DeliveryLineID) VALUES (@Path, @DeliveryLineID);
                                SELECT @AttachmentID = SCOPE_IDENTITY()"
                UpdateCommand="UPDATE Delivery.Attachment SET FileName = @FileName WHERE AttachmentID = @AttachmentID"
                DeleteCommand="DELETE FROM Delivery.Attachment WHERE AttachmentID = @AttachmentID"
                OnInserted="SqlDataSource_Attachments_Inserted">
                <SelectParameters>
                    <asp:ControlParameter Name="DeliveryLineID" ControlID="GridViewDeliveryLines" PropertyName="SelectedValue" />
                </SelectParameters>
                <InsertParameters>
                    <asp:Parameter Name="Path" />
                    <asp:ControlParameter Name="DeliveryLineID" ControlID="GridViewDeliveryLines" PropertyName="SelectedValue" />
                    <asp:Parameter Name="AttachmentID" Direction="Output" Type="Int32" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="FileName" /><%--Filename is updated later, because ID (IDENTITY field) is included in filename--%>
                    <asp:Parameter Name="AttachmentID" />
                </UpdateParameters>
                    <%--
                    CREATE TRIGGER [Delivery].[trAttachment]  ON  [Delivery].[Attachment]
                        AFTER INSERT
                    AS 
                        UPDATE Delivery.Attachment
                        SET Delivery.Attachment.[FileName] = CAST(i.AttachmentID as varchar) + '.' + i.[FileName]
                        FROM Delivery.Attachment t2
                        INNER JOIN INSERTED i ON i.AttachmentID = t2.AttachmentID
                    --%>
                <DeleteParameters>
                    <asp:Parameter Name="AttachmentID" DefaultValue="0" />
                </DeleteParameters>
            </asp:SqlDataSource>
        </td>
    </tr>
</table>
</asp:Content>
