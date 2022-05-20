# presale

Projeto FILA AGIL


## Finalidade

Fila agil tem por finalidade agilizar o atendimento nas filas das lojas. Onde a função é coletar os produtos e gerar uma prevenda.
Assim quando chegar no caixa o cliente irá passar somente o número da prevenda e finalizar a sua compra

## Desenvolvimento

### Requisitos

	- Desenvolvido em FLUTTER
	- Versão Flutter 1.22.2
	- Versão SDK Dart 

### Funcionamento
	- O presale inicia solicitando a filial na qual está sendo realizado a pré-venda. Para essa listagem, o aplicativo acessa a API: rmcweb.gruporcarvalho.com.br/api/v1/organizations. Assim, ele lista todas as filiais e informa na tela, logo seu funcionamento será à base de conexão com a internet. Caso o dispositivo não tenha nenhum conexão com a internet, a aplicação irá alertar o usuário e fechará a aplicação para evitar problemas no seu funcionamento.
	- Ao informar a filial, o aplicativo redicionará o usuário para a rota /home, onde o mesmo informará o nome do cliente e fará a bipagem dos produtos.
	- Ao bipar um produto, aparecerá uma aba com sua informação, e o usuário poderá selecionar a quantidade do produto que será registrada.
	- Na parte superior do aplicativo, você pode perceber que existe algumas informações, sendo elas: Nome do aplicativo (por padrão: 'Fila Ágil'), Nome do cliente e em caso de bipagem do produto, o valor total a ser pago.
	- O aplicativo terá algumas opções adicionais, representadas por "três pontos".

	Opção Salvar Cesta: O aplicativo realiza um POST na API: https://rmcweb.gruporcarvalho.com.br/api/v1/organizations/${loja}/orders/ informando quantidade de itens pedido, valor total pedido, itens, entre outros dados. Ao final, ele irá apresentar o número de pedido do cliente, no qual o cliente informará no momento do pagamento.

	Opção Deletar Cesta: O aplicativo limpa todos os produtos que foram bipados de uma só vez.

	Opção Sair do App: O aplicativo sairá do aplicativo, deixando salvos os produtos já bipados das respectivas lojas, porém o nome do usuário deverá ser informado novamente.

	Opção Pedidos Pendentes: O aplicativo acessará a API: https://rmcweb.gruporcarvalho.com.br/api/v1/organizations/${loja}/orders para listar todos os pedidos pendentes dos clientes, informando o número do pedido, data e hora da emissão e o total a ser pago.

	Opção de Edição: Você encontrará essa opção pressionando o produto bipado, identificado por um lápis verde, que abrirá a mesma caixa onde o usuário poderá editar a quantidade de itens.

	Opção de Deletar Produto Individualmente: Você encontrará essa opção pressionando o produto bipado, identificado por uma lixeira vermelha, que ao ser clicada, removerá o produto instantanemante.

	- O presale acessa a API do RCMWEB para realizar a consulta dos PRODUTOS e criar uma nova ORDEM
	- API: rmcweb.gruporcarvalho.com.br/api/v1/organizations

### Informações Adicionais

	- A aplicação tem algumas facilidades no momento de inserir o produto. Um botão virtual, que ao clicar, ligará o leitor do coletor. Também há uma opção que o usuário poderá inserir manualmente o código de barras do produto e uma terceira opção que a bipagem do produto poderá ser realizada pela câmera do celular e/ou smarthphone.

	-	o presale acessa a API do RCMWEB para realizar a consulta dos PRODUTOS e criar uma nova ORDEM
	-	API: rmcweb.gruporcarvalho.com.br/api/v1/organizations
	
### Rotas Acessadas

	- Consulta de produtos: GET rmcweb.gruporcarvalho.com.br/api/v1/organizations/{:organization_id}/products/{:product_code}
	- Gerar uma nova Ordem: POST rmcweb.gruporcarvalho.com.br/api/v1/organizations/{:organization_id}/orders
