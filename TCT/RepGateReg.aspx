<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" EnableViewState="false" CodeBehind="RepGateReg.aspx.cs" Inherits="TCT.RepGateReg" %>
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
    &nbsp;&nbsp;

    Line ID:
    <asp:TextBox ID="LineIDTextBox" runat="server" onchange="this.value=this.value.trim()" />
    <br /><br />

    Freight Bill:
    <asp:TextBox ID="FBTextBox" runat="server" onchange="this.value=this.value.trim()" />
    &nbsp;&nbsp;

    Gate Reg:
    <asp:TextBox ID="GRTextBox" runat="server" onchange="this.value=this.value.trim()" />
    &nbsp;&nbsp;

    AK:
    <asp:DropDownList ID="AccountingEntryDropDownList" runat="server">
        <asp:ListItem></asp:ListItem>
        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
        <asp:ListItem Value="0" Text="No"></asp:ListItem>
    </asp:DropDownList>
    &nbsp;&nbsp;

    TERM:
    <asp:DropDownList ID="TermDropDownList" runat="server">
        <asp:ListItem></asp:ListItem>
        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
        <asp:ListItem Value="0" Text="No"></asp:ListItem>
    </asp:DropDownList>
    &nbsp;&nbsp;

    Customs Cleared:
    <asp:DropDownList ID="CustomsClearedDropDownList" runat="server">
        <asp:ListItem></asp:ListItem>
        <asp:ListItem Value="1" Text="Yes"></asp:ListItem>
        <asp:ListItem Value="0" Text="No"></asp:ListItem>
    </asp:DropDownList>
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
    <asp:GridView ID="GridViewReport_5" runat="server" CellPadding="2" GridLines="Vertical" AutoGenerateColumns="False"
        DataSourceID="SqlDataSource_Report_5" DataKeyNames="DeliveryLineID" AllowPaging="True" PageSize="1000" AllowSorting="True"
        OnRowDataBound="GridViewReport_5_RowDataBound">
        <EmptyDataTemplate>No Gate Registrations found with this filter</EmptyDataTemplate>
        <Columns>
            <asp:BoundField DataField="DeliveryID"        HeaderText="Gate Reg."            SortExpression="DeliveryID" />
            <asp:BoundField DataField="CreateDate"        HeaderText="Created"              SortExpression="CreateDate" DataFormatString="{0:dd.MM.yyyy hh:mm}" />
            <asp:BoundField DataField="T1Number"          HeaderText="T1Number"             SortExpression="T1Number" />
            <asp:BoundField DataField="Forwarder"         HeaderText="Forwarder"            SortExpression="Forwarder" />
            <asp:BoundField DataField="Truck"             HeaderText="Truck"                SortExpression="Truck" />
            <asp:BoundField DataField="DeliveryLineID"    HeaderText="Line ID"              SortExpression="DeliveryLineID" />
            <asp:BoundField DataField="FreightBillNumber" HeaderText="Freight Bill"         SortExpression="FreightBillNumber" />
            <asp:BoundField DataField="Urgent"            HeaderText="Urgent"               SortExpression="Urgent" />
            <asp:BoundField DataField="Supplier"          HeaderText="Supplier"             SortExpression="Supplier" />
            <asp:BoundField DataField="CountryOfDispatch" HeaderText="Dispatch"             SortExpression="CountryOfDispatch" />
            <asp:BoundField DataField="Incoterm"          HeaderText="Inco- term"           SortExpression="Incoterm" />
            <asp:BoundField DataField="GrossWeight"       HeaderText="Gross Weight"         SortExpression="GrossWeight" />
            <asp:BoundField DataField="PackageCount1"     HeaderText="PackageType1 Count"   SortExpression="PackageCount1" />
            <asp:BoundField DataField="PackageType1"      HeaderText="PackageType1"         SortExpression="PackageType1" />
            <asp:BoundField DataField="PackageCount2"     HeaderText="PackageType2 Count"   SortExpression="PackageCount2" />
            <asp:BoundField DataField="PackageType2"      HeaderText="PackageType2"         SortExpression="PackageType2" />
            <asp:BoundField DataField="PackageCount3"     HeaderText="PackageType3 Count"   SortExpression="PackageCount3" />
            <asp:BoundField DataField="PackageType3"      HeaderText="PackageType3"         SortExpression="PackageType3" />
            <asp:BoundField DataField="AK"                HeaderText="AK"                   SortExpression="AK" />
            <asp:BoundField DataField="TERM"              HeaderText="TERM"                 SortExpression="TERM" />
            <asp:BoundField DataField="CustomsCleared"    HeaderText="Customs Cleared"      SortExpression="CustomsCleared" />
            <asp:BoundField DataField="Comment"           HeaderText="Comment"              SortExpression="Comment" />
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:Repeater ID="RepeaterReport_Inner" runat="server">
                        <ItemTemplate>
                            <a href="<%# Container.DataItem %>" target="_blank"><img src="Images/file-icon.jpg" alt="" /></a>
                            <%--  <%# System.IO.Path.GetFileName(Container.DataItem.ToString()) %>  --%>
                            <%--  Container.DataItem [2] ?!?     <asp:BoundField DataField="CreateDate" DataFormatString="{0:g}" ItemStyle-Font-Size="Smaller" />  --%>
                        </ItemTemplate>
                    </asp:Repeater>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <HeaderStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <PagerSettings Position="TopAndBottom" />
        <AlternatingRowStyle BackColor="#DDEEFF" />
        <SortedAscendingCellStyle BackColor="#F5F7FB" />
        <SortedAscendingHeaderStyle BackColor="#6D95E1" />
        <SortedDescendingCellStyle BackColor="#E9EBEF" />
        <SortedDescendingHeaderStyle BackColor="#4870BE" />
    </asp:GridView>
    
    <asp:SqlDataSource ID="SqlDataSource_Report_5" runat="server" CancelSelectOnNullParameter="false" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT h.DeliveryID
                ,h.CreateDate
                ,h.T1Number
                ,f.Name [Forwarder]
                ,h.TruckRegistrationNumber [Truck]
                ,l.DeliveryLineID
                ,l.FreightBillNumber
                ,s.Name [Supplier]
                ,l.CountryOfDispatch
                ,l.Incoterm
                ,l.GrossWeight
                ,l.PackageCount1
                ,p.PackageType [PackageType1]
                ,l.PackageCount2
                ,pp.PackageType [PackageType2]
                ,l.PackageCount3
                ,ppp.PackageType [PackageType3]
                ,AK = CASE l.IsAccountingEntry WHEN 1 THEN 'AK' ELSE '' END
                ,TERM = CASE l.IsTerm WHEN 1 THEN 'TERM' ELSE '' END
                ,CustomsCleared = CASE l.IsCustomsCleared WHEN 1 THEN 'yes' ELSE '' END
                ,l.Comment
                ,Urgent = CASE n.IsUrgent WHEN 1 THEN 'Urgent' ELSE '' END
                ,STUFF((
                        SELECT ',' + a.Path + a.FileName FROM Delivery.Attachment a
                        WHERE a.DeliveryLineID = l.DeliveryLineID FOR xml path('')
                    ),1,1,'') [Attachments]
            FROM Delivery.DeliveryHeader h
            INNER JOIN Delivery.DeliveryLine l ON h.DeliveryID = l.DeliveryID
            INNER JOIN Delivery.Forwarder f ON h.ForwarderID = f.ForwarderID
            INNER JOIN Delivery.Supplier s ON l.SupplierID = s.SupplierID
            LEFT JOIN Delivery.Notify n ON l.FreightBillNumber = n.FreightBillNumber
            LEFT JOIN Delivery.PackageType1 p ON p.PackageType = l.PackageType1
            LEFT JOIN Delivery.PackageType2 pp ON pp.PackageType = l.PackageType2
            LEFT JOIN Delivery.PackageType3 ppp ON ppp.PackageType = l.PackageType3
            WHERE   (@ForwarderID       IS NULL OR h.ForwarderID = @ForwarderID)
                AND (@SupplierID        IS NULL OR l.SupplierID  = @SupplierID)
                AND (@DeliveryLineID    IS NULL OR l.DeliveryLineID LIKE'%' +  @DeliveryLineID + '%')
                AND (@FreightBillNumber IS NULL OR l.FreightBillNumber LIKE '%' + @FreightBillNumber + '%')
                AND (@DeliveryID        IS NULL OR h.DeliveryID LIKE '%' + @DeliveryID + '%')
                AND (@IsAccountingEntry IS NULL OR l.IsAccountingEntry  = @IsAccountingEntry)
                AND (@IsTerm            IS NULL OR l.IsTerm             = @IsTerm)
                AND (@IsCustomsCleared  IS NULL OR l.IsCustomsCleared   = @IsCustomsCleared)
                AND h.CreateDate &gt; GETDATE()-CAST(@CreateDateDiff as int)
            ORDER BY h.CreateDate DESC">
        <SelectParameters>
            <asp:ControlParameter Name="ForwarderID" ControlID="ForwarderDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="SupplierID" ControlID="SupplierDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="DeliveryLineID" ControlID="LineIDTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="FreightBillNumber" ControlID="FBTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="DeliveryID" ControlID="GRTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="IsAccountingEntry" ControlID="AccountingEntryDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="IsTerm" ControlID="TermDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="IsCustomsCleared" ControlID="CustomsClearedDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="CreateDateDiff" ControlID="CreateDateDropDownList" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:SqlDataSource>

</asp:Content>
