<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetCurrencies.aspx.cs" Inherits="TCT.SetCurrencies" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Name: <asp:TextBox ID="NewCurrencyNameTextBox" runat="server" Width="200" CssClass="grey"/> &nbsp; 
    Code: <asp:TextBox ID="NewCurrencyCodeTextBox" runat="server" Width="50" CssClass="grey"/> &nbsp; 
    Exchange Rate: <asp:TextBox ID="NewCurrencyExchangeRateTextBox" runat="server" Width="100" CssClass="grey"/> &nbsp; 
                    <asp:RegularExpressionValidator ID="RegExValidatorExchangeRate" runat="server" ErrorMessage="* Please insert a number"
                        ControlToValidate="NewCurrencyExchangeRateTextBox" ValidationGroup="InsertNew Currency" CssClass="red" Display="Dynamic" ValidationExpression="^\d+([,.]\d+)?$" />
    <asp:Button ID="NewCurrencyButton" runat="server" Text="Create New Currency" OnClick="NewCurrencyButton_Click"/>
        
    <asp:GridView ID="GridViewCurrency" runat="server" AutoGenerateColumns="false" CellPadding="4" ForeColor="#333333" GridLines="None" 
        DataKeyNames="CurrencyID" DataSourceID="SqlDataSource_Currency" EnablePersistedSelection="true">
        <AlternatingRowStyle BackColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowEditButton="true" />
            <asp:BoundField DataField="Name" HeaderText="Currency"/>
            <asp:BoundField DataField="Code" HeaderText="Code"/>
            <asp:BoundField DataField="ExchangeRate" HeaderText="ExchangeRate"/>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:LinkButton ID="DeleteCurrencyButton" runat="server" CommandName="delete" Text="X"
                        ControlStyle-ForeColor="Red" ControlStyle-Font-Bold="true" ControlStyle-Font-Underline="false"
                        OnClientClick="if (!window.confirm('Delete this Currency?')) return false;" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <RowStyle BackColor="#EFF3FB" />
        <EditRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Currency" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT CurrencyID, Name, Code, ExchangeRate FROM PurchaseOrder.Currency ORDER BY Name" 
        InsertCommand="INSERT INTO PurchaseOrder.Currency (Name, Code, ExchangeRate) VALUES (@Name, @Code, REPLACE(@ExchangeRate, ',', '.'))" 
        UpdateCommand="UPDATE PurchaseOrder.Currency SET Name = @Name, Code = @Code, ExchangeRate = REPLACE(@ExchangeRate, ',', '.') WHERE CurrencyID = @CurrencyID"
        DeleteCommand="DELETE FROM PurchaseOrder.Currency WHERE CurrencyID = @CurrencyID">
        <InsertParameters>
            <asp:ControlParameter Name="Name" ControlID="NewCurrencyNameTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="Code" ControlID="NewCurrencyCodeTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="ExchangeRate" ControlID="NewCurrencyExchangeRateTextBox" PropertyName="Text" Type="Double"/>
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Name" />
            <asp:Parameter Name="Code" />
            <asp:Parameter Name="ExchangeRate" Type="Double"/>
            <asp:Parameter Name="CurrencyID" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="CurrencyID" />
        </DeleteParameters>
    </asp:SqlDataSource>

</asp:Content>
