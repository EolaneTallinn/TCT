<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" EnableViewState="false" CodeBehind="RepReceivedAK.aspx.cs" Inherits="TCT.RepReceivedAK" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Forwarder:
    <asp:DropDownList ID="ForwarderDropDownList" runat="server"
        DataSourceID="SqlDataSource_Forwarder" DataTextField="Name" DataValueField="ForwarderID" AppendDataBoundItems="True">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <asp:SqlDataSource ID="SqlDataSource_Forwarder" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT ForwarderID, Name FROM Delivery.Forwarder ORDER BY Name">
    </asp:SqlDataSource>
    &nbsp;&nbsp;

    Supplier:
    <asp:DropDownList ID="SupplierDropDownList" runat="server"
        DataSourceID="SqlDataSource_Supplier" DataTextField="Name" DataValueField="SupplierID" AppendDataBoundItems="True">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <asp:SqlDataSource ID="SqlDataSource_Supplier" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT SupplierID, Name FROM Delivery.Supplier ORDER BY Name">
    </asp:SqlDataSource>
    <br /><br />

    Freight Bill:
    <asp:TextBox ID="FBTextBox" runat="server" onchange="this.value=this.value.trim()" />
    &nbsp;&nbsp;

    Timeframe:
    <asp:DropDownList ID="CreateDateDropDownList" runat="server" AutoPostBack="true">
        <asp:ListItem Value="30" Text="Last 30 days" />
        <asp:ListItem Value="183" Text="Last 6 months" />
        <asp:ListItem Value="365" Text="Last 12 months" />
        <asp:ListItem Value="1825" Text="Last 5 years" />
    </asp:DropDownList>
    &nbsp;&nbsp;

    <asp:Button ID="ShowButton" runat="server" Text="Show Report" />
    <asp:Button ID="ExportButton" runat="server" Text="Export to CSV" OnClick="ExportButton_Click"/>
    <br />
    <br />
    <asp:GridView ID="GridViewReport" runat="server" CellPadding="2" GridLines="Vertical" AutoGenerateColumns="False"
        DataSourceID="SqlDataSource_Report" DataKeyNames="PurchaseOrderLineID" AllowPaging="True" PageSize="1000" AllowSorting="True"
        OnRowDataBound="GridViewReport_RowDataBound">
        <EmptyDataTemplate>No record found with this filter</EmptyDataTemplate>
        <Columns>
            <asp:BoundField DataField="T1Number"          HeaderText="T1Number"      SortExpression="T1Number" />
            <asp:BoundField DataField="CreateDate"        HeaderText="G.R. Created"  SortExpression="CreateDate" DataFormatString="{0:dd.MM.yyyy hh:mm}" />
            <asp:BoundField DataField="Forwarder"         HeaderText="Forwarder"     SortExpression="Forwarder" />
            <asp:BoundField DataField="FreightBillNumber" HeaderText="Freight Bill"  SortExpression="FreightBillNumber" />
            <asp:BoundField DataField="PO Number/Line" HeaderText="PO Number/Line"  SortExpression="PO Number/Line" />
<%--            <asp:BoundField DataField="DeliveryID"  HeaderText="DeliveryID"     SortExpression="DeliveryID" />
            <asp:BoundField DataField="AccountingEntry"   HeaderText="AK"            SortExpression="AccountingEntry" />--%>
            <asp:BoundField DataField="Line"   HeaderText="AK Number"            SortExpression="Line" />
            <asp:BoundField DataField="AccountingEntryType"   HeaderText="Type"            SortExpression="AccountingEntryType" />
            <asp:BoundField DataField="Supplier"          HeaderText="Supplier"      SortExpression="Supplier" />
            <asp:BoundField DataField="CountryOfDispatch" HeaderText="Dispatch"        SortExpression="CountryOfDispatch" />
            <asp:BoundField DataField="ItemID"            HeaderText="Item Code"     SortExpression="ItemID" />
            <asp:BoundField DataField="Description"       HeaderText="Item Description"     SortExpression="Description" />
            <asp:BoundField DataField="DeliveredQuantity" HeaderText="Qty"           SortExpression="DeliveredQuantity" />
            <asp:BoundField DataField="Amount"            HeaderText="Value"         SortExpression="Amount" DataFormatString="{0:F2}" />
            <asp:BoundField DataField="GrossWeight"       HeaderText="Gross Weight"         SortExpression="GrossWeight"/>
            <asp:BoundField DataField="PackageCount"      HeaderText="Package Count"         SortExpression="PackageCount"/>
            <asp:BoundField DataField="DocumentCurrency"  HeaderText="Currency"      SortExpression="DocumentCurrency" />
            <asp:BoundField DataField="CustomsCode"       HeaderText="Customs Code"  SortExpression="CustomsCode" />
            <asp:BoundField DataField="CountryOfOrigin"    HeaderText="Origin"       SortExpression="CountryOfOrigin" />
            <asp:BoundField DataField="IsCustomHandled"    HeaderText="PUCC"         SortExpression="IsCustomHandled" />
            <asp:BoundField DataField="InvoiceNumber"      HeaderText="Invoice"      SortExpression="InvoiceNumber" />
            <asp:BoundField DataField="DeclarationType"    HeaderText="Decl.Type"    SortExpression="DeclarationType" />
            <asp:BoundField DataField="DeclarationNumber"  HeaderText="Decl.Num"     SortExpression="DeclarationNumber" />
            <asp:BoundField DataField="DeclarationDate"    HeaderText="Decl.Date"    SortExpression="DeclarationDate" DataFormatString="{0:dd.MM.yyyy}" />
        </Columns>
        <FooterStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <HeaderStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <AlternatingRowStyle BackColor="#DDEEFF" />
        <SortedAscendingCellStyle BackColor="#F5F7FB" />
        <SortedAscendingHeaderStyle BackColor="#6D95E1" />
        <SortedDescendingCellStyle BackColor="#E9EBEF" />
        <SortedDescendingHeaderStyle BackColor="#4870BE" />
    </asp:GridView>
    
    <asp:SqlDataSource ID="SqlDataSource_Report" runat="server" CancelSelectOnNullParameter="false" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT po.PurchaseOrderLineID
                ,po.FreightBillNumber
                ,CASE po.AccountingEntry When NULL THEN '' ELSE 'IMG' END AccountingEntryType
                ,po.ItemID
                ,po.Description
                ,po.PONumber + '/' + po.POLineNumber AS [PO Number/Line]

                        ,po.DeliveredQuantity
                        ,po.Amount
                ,[GrossWeight] = Case When po.PurchaseOrderLineID = (select min(ln.PurchaseOrderLineID) from PurchaseOrder.PurchaseOrder ln Where ln.FreightBillNumber = po.FreightBillNumber)
                                                                  Then l.GrossWeight Else null End
                ,[PackageCount] = Case When po.PurchaseOrderLineID = (select min(ln.PurchaseOrderLineID) from PurchaseOrder.PurchaseOrder ln Where ln.FreightBillNumber = po.FreightBillNumber)
                                                                  Then l.PackageCount Else null End
                        ,po.DocumentCurrency
                        ,po.CustomsCode
                        ,po.InvoiceNumber
                        ,po.DeclarationType
                        ,po.DeclarationNumber
                        ,po.DeclarationDate
                        ,po.CountryOfOrigin
                        ,CASE po.IsCustomHandled WHEN 1 THEN 'PUCC' ELSE '' END IsCustomHandled
                ,h.T1Number
                ,h.CreateDate
                ,f.Name [Forwarder]
                ,s.Name [Supplier]
                ,FORMAT(h.CreateDate,'yyyy') + '/' + CAST(l.DeliveryID as varchar(10)) + '/' + CAST(po.AccountingEntry as varchar(10)) AS [Line]
                ,l.CountryOfDispatch               

            FROM PurchaseOrder.PurchaseOrder po
            INNER JOIN Delivery.DeliveryLine l ON po.FreightBillNumber = l.FreightBillNumber
            INNER JOIN Delivery.DeliveryHeader h ON l.DeliveryID = h.DeliveryID
            INNER JOIN Delivery.Supplier s ON l.SupplierID = s.SupplierID
            INNER JOIN Delivery.Forwarder f ON h.ForwarderID = f.ForwarderID
            WHERE   (@FreightBillNumber IS NULL OR po.FreightBillNumber LIKE '%' + @FreightBillNumber + '%')
                AND (@ForwarderID       IS NULL OR h.ForwarderID = @ForwarderID)
                AND (@SupplierID        IS NULL OR l.SupplierID  = @SupplierID)
                AND po.IsFinished = 1
                AND po.AccountingEntry &gt; 0
                AND h.CreateDate &gt; GETDATE()-CAST(@CreateDateDiff as int)">
        <SelectParameters>
            <asp:ControlParameter Name="ForwarderID" ControlID="ForwarderDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="SupplierID" ControlID="SupplierDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="FreightBillNumber" ControlID="FBTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="CreateDateDiff" ControlID="CreateDateDropDownList" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:SqlDataSource>

</asp:Content>
