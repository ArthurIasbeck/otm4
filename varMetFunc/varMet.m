function [xOpt, fOpt, nVal, k, alfaValues] = varMet(f, x0, df, tol, theta, h)

% Verificação de erros na entrada
if nargin < 2 || isempty(f) || isempty(x0)
    disp('Informe x0 e f!');
    return;
end

% Verificação da entrada do gradiente
if nargin < 3 || isempty(df)
    if nargin < 6 || isempty(h)
        df = @(x) grad(f,x);
    else
        f = @(x) grad(f,x,h);
    end
    numGrad = 1;
else
    numGrad = 0;
end

% Definição das entradas padrão
if nargin < 4 || isempty(tol)
    tol = 1e-5;
end

if nargin < 5 || isempty(theta)
    theta = 1;
end

% Variáveis para controle de execução
n = length(x0);
alfaValues = zeros(1,1);
k = 1;
nVal = 0;
H = eye(n);

while 1 
    % Reduzir a dimensão do problema de otimização
    g = @(alfa) f(x0 - alfa*H*df(x0));
    
    % Resolver o problema de otimização uni-dimensional
    [alfaOpt,~,nVal1] = aureaSec(g,-1,1,1e-4);
    
    % Atualizar a solução ótima
    x = x0 - alfaOpt*H*df(x0);
    
    % Armazenar dados de execução 
    alfaValues(k) = alfaOpt;
    if numGrad 
        nVal = nVal + nVal1 + 1; 
    else
        nVal = nVal + nVal1 + 2*n;
    end
    
    % OBS : Lembre-se que é necessária a computação do gradiente para
    % atualização de x. No entanto, se estivermos utilizando a aproximação
    % numérica para o gradiente, a computação do mesmo levará, neste caso a
    % 6 avaliações da função objetivo.
   
    % Verificar a condição de parada
    cp = norm(x - x0);
    if cp < tol
        break;
    end
    
    % Atualização de H (aproximação para a inversa da Matriz Hessiana)
    p = x - x0;
    y = df(x) - df(x0);
    sigma = p'*y;
    tal = y'*H*y;
    D = ((sigma + theta*tal)/sigma^2)*(p*p') ...
        + ((theta - 1)/tal)*(H*y)*(H*y)' ...
        - (theta/sigma)*(H*y*p' + p*(H*y)');
    
    H = H + D;

    % Atualizar variáveis para a próxima iteração
    x0 = x;
    k = k + 1;
end

xOpt = x;
fOpt = f(xOpt);