# Avarias

Projeto SISTEMA AVARIAS


## Finalidade

Agilizar o sistema de balanço e vendas de avarias, trazendo mais praticidade e controle.

## Desenvolvimento

### Versão do Aplicativo

	- Aplicativo desenvolvido na versão 1.0.0.

### Requisitos

	- Desenvolvido em FLUTTER
	- Versão Flutter 1.22.2
	- Versão SDK Dart 

### Funcionamento
	
	O aplicativo MÓVEL AVARIAS possui dois sistemas disponível no aplicativo.
	Ao iniciar o aplicativo, o usuário colocará a matrícula do funcionário e escolherá em qual sistema será realizado a operação. 

	- BALANÇO: Ao clicar em balanço, o usuário será encaminhado para uma tela padrão de bipagem de produtos, ficando disponível o registro de podrutos pelo laser ou inserindo o código de barras manualmente. Ao informar o produto que estará sendo registrado, o aplicativo abrirá uma tela com as informações do produto que foi informado, como código de barras, descrição do produto e o código único do mesmo. Caso o código do produto não seja encontrado, ele solicitará para que o usuário informe o código e isso deixará salvo no sistema ao salvar a cesta. Da próxima vez que o produto for bipado, não será mais possível alterar seu código e ficará visível qual código foi inserido naquele produto, podendo editar somente a sua quantidade. Salvando o produto, as informações serão armazenadas no sistema de balanço, ainda não registrando nenhuma informação. Segurando no card do produto, abrirá algumas informações como editar a quantidade do produto que foi bipado ou excluir o produto selecionado. Há também uma opção de deletar toda a cesta presente no meu de opções identificado pelos três pontos na parte superior do aplicativo.
	Ao salvar a cesta, além de registrar seu código que foi inserido pelo usuário, os produtos serão lançados e ficarão disponíveis para a venda, onde isso será interagido diretamente com o sistema de pré-venda.

	- PREVENDA: Voltando ao menu inicial do aplicativo e entrando no sistema de pré-venda, o usuário irá ser direcionado para uma lista de pré-vendas que estão em andamento, onde irá trazer algumas informações como: nome do cliente e número da pré-venda (ambos poderão ser informados no caixa para a realização do pagamento), tão como a quantidade de produtos na cesta dessa pré-venda, data de abertura e o valor total. Na mesma janela, existe uma caixa de opções identificado por três pontos, onde o usuário poderá realizar a criação de uma nova pré-venda. Ao clicar nessa opção, abrirá uma lista de clientes cadastrados no sistema e ao clicar em um, será realizado a criação da pré-venda automaticamente. Caso já exista alguma pré-venda que foi clicada em andamento, o aplicativo reconhecerá e avisará ao usuário se ele pretende iniciar uma nova pré-venda desse usuário ou deseja continuar com a pré-venda já existente. Ao clicar em criar uma nova pré-venda, a lista será deletada e o usuário será informado que uma nova pré-venda foi criada.
	Ao clicar dentro de uma pré-venda, o usuário será encaminhado para a cesta de pré-venda do respectivo cliente e poderá realizar a mesma função de bipagem, por laser, código de barras ou código do produto. Ao salvar o produto e sua quantidade, suas informações já estarão vinculadas diretamente no caixa e poderá ser acessados através do nome do cliente e número de pré-venda. Quando a venda for finalizada e a pré-venda encerrada, o usuário não terá mais acesso a mesma. O usuário também poderá cancelar a pré-venda em andamento pelo aplicativo móvel em "cancelar pré-venda".

### Informações Adicionais

	API().urlApi: http://10.86.200.235/
	
	Lista de rotas da API presente nesta aplicação estão disponíveis no README.md do repositório controle_avarias.