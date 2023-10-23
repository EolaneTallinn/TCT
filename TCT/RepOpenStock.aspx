<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" EnableViewState="false" CodeBehind="RepOpenStock.aspx.cs" Inherits="TCT.RepOpenStock" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    Check Stock status on: 
    <asp:TextBox ID="StockDateTextBox" runat="server" AutoPostBack="True" CssClass="grey" />
    <ajax:CalendarExtender ID="StockDateCalendarExtender" runat="server" TargetControlID="StockDateTextBox" 
        FirstDayOfWeek="Monday" Format="dd.MM.yyyy">
    </ajax:CalendarExtender>
    <br />
    Filter out - Show only materials which belong into the BOM of this Product Code:
    <asp:TextBox ID="CompareItemCodeTextBox" runat="server" CssClass="grey" />
    <asp:Button ID="CompareItemCodeButton" runat="server" Text="Apply filter" />
    <asp:LinkButton ID="CompareItemCodeResetLinkButton" runat="server" Text="Remove Filter" CssClass="red" OnClick="CompareItemCodeResetLinkButton_Click" />
    <br />
    <br />
    <asp:Label ID="PastDateWarningLabel" runat="server" Text="" Font-Size="Large" CssClass="red" />
    <br />
    
    <asp:GridView ID="GridViewReport_2" runat="server" CellPadding="3" GridLines="Vertical" AutoGenerateColumns="False"
        DataSourceID="SqlDataSource_Report_2" DataKeyNames="ItemID" AllowPaging="True" PageSize="1000" AllowSorting="True"
        OnRowDataBound="GridViewReport_2_RowDataBound" >
        <EmptyDataTemplate>
            No components found in PUCC stock<br />
            <% if (CompareItemCodeTextBox.Text.Length > 0) { Response.Write("NOTE: Currently showing only components of the product: <b>" + CompareItemCodeTextBox.Text + "</b>"); } %>
        </EmptyDataTemplate>
        <Columns>
            <asp:BoundField DataField="ItemID"            HeaderText="Item" SortExpression="ItemID" />
            <asp:BoundField DataField="Description"       HeaderText="Description" SortExpression="Description" />
            <asp:BoundField DataField="CustomsCode"       HeaderText="Customs Code" SortExpression=" CustomsCode" />
            <asp:BoundField DataField="CountryOfOrigin"   HeaderText="Origin" SortExpression="CountryOfOrigin" />
            <asp:BoundField DataField="PONumber"          HeaderText="PO Number" SortExpression="PONumber" />
            <asp:BoundField DataField="AccountingEntry"   HeaderText="AK" SortExpression="AccountingEntry" />
            <asp:BoundField DataField="DeclarationType"   HeaderText="Type" SortExpression="DeclarationType" />
            <asp:BoundField DataField="DeclarationNumber" HeaderText="Import Decl." SortExpression="DeclarationNumber" />
            <asp:BoundField DataField="DeclarationDate"   HeaderText="Decl.Date" SortExpression="DeclarationDate" DataFormatString="{0:dd.MM.yyyy}" />
            <asp:BoundField DataField="DeclarationExpiry" HeaderText="Decl.Exp." SortExpression="DeclarationExpiry" DataFormatString="{0:dd.MM.yyyy}" />
            <asp:BoundField DataField="OriginalQuantity"  HeaderText="Received Qty" SortExpression="OriginalQuantity" />
            <asp:BoundField DataField="ActualQuantity"    HeaderText="Stock Qty" SortExpression="ActualQuantity" />
            <asp:BoundField DataField="UnitPriceInLC"     HeaderText="Unit Price" SortExpression="UnitPriceInLC" />
            <asp:BoundField DataField="LocalCurrency"     HeaderText="Currency" SortExpression="LocalCurrency" />
        </Columns>
        <FooterStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <HeaderStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <EmptyDataRowStyle CssClass="red" />
        <AlternatingRowStyle BackColor="#DDEEFF" />
        <SortedAscendingCellStyle BackColor="#F5F7FB" />
        <SortedAscendingHeaderStyle BackColor="#6D95E1" />
        <SortedDescendingCellStyle BackColor="#E9EBEF" />
        <SortedDescendingHeaderStyle BackColor="#4870BE" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Report_2" runat="server" CancelSelectOnNullParameter="false"
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT Stock.ItemID 
                ,PO.[Description]
                ,PO.CustomsCode 
                ,PO.CountryOfOrigin 
                ,PO.PONumber
                ,PO.AccountingEntry
                ,PO.DeclarationType
                ,PO.DeclarationNumber
                ,PO.DeclarationDate
                ,PO.DeclarationExpiry
                ,Stock.OriginalQuantity
                ,Stock.ActualQuantity
                ,PO.UnitPriceInLC 
                ,PO.LocalCurrency 
            FROM Customs.StockHistory Stock
            INNER JOIN PurchaseOrder.PurchaseOrder PO ON Stock.PurchaseOrderLineID = PO.PurchaseOrderLineID
            WHERE Stock.ActualQuantity &gt; 0  AND StockHistoryID IN
                (SELECT MAX(StockHistoryID) FROM Customs.StockHistory 
                    WHERE @StockDate IS NULL OR [Date] &lt; CONVERT(datetime, @StockDate, 104) + 1
                    GROUP BY StockID)
                AND (@RootItemCode IS NULL OR Stock.ItemID IN (SELECT DISTINCT ItemCode FROM Customs.Bom WHERE RootItemCode = @RootItemCode AND IsComponent = 1))
            ORDER BY Stock.ItemID">
        <SelectParameters>
            <asp:ControlParameter Name="StockDate" ControlID="StockDateTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="RootItemCode" ControlID="CompareItemCodeTextBox" PropertyName="Text" />
        </SelectParameters>
    </asp:SqlDataSource>

    <%-- Open Stock Summary --%>
    <br />
    <table>
        <tr><td>Total Open Stock Qty:</td>
            <td><asp:Label ID="TotalQuantityLabel" runat="server" Font-Bold="True" /> pcs.</td>
        </tr>
        <tr><td>Total value:</td>
            <td><asp:Label ID="TotalValueLabel" runat="server" Font-Bold="True" /> EUR</td>
        </tr>
        <tr><td>Estimated Customs Value:</td>
            <td><asp:Label ID="CustomsValueLabel" runat="server" Font-Bold="True" /> EUR</td>
        </tr>
    </table>

</asp:Content>
