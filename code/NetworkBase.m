classdef NetworkBase
    % I thought we will inherit this for a outer class but it looks like we
    % do not need to right now. So the name might not be very appropriate
    properties(SetAccess = public)
        list_nodes = cell(0);
        connectionMat;
        connectionDelayMat;
        a;
        b;
    end
    methods
        function this = NetworkBase(varargin)
            switch nargin
                case 0
                    this.a = 4;
                    this.b = 3;
                case 2
                    this.a = varargin{1};
                    this.b = varargin{2};
                otherwise
                    error('Wrong number of arguments');
            end
        end
        function this = connectAstoBs(this, As, Bs, StrengthMat, DelayMat)
            %directed connection from A to B
            len_As = length(As);
            len_Bs = length(Bs);
            num_elem = length(this.list_nodes);
            if(As > num_elem || Bs > num_elem)
                error('Trying to connect invalid nodes. Add first');
            end
            switch nargin
                case 3
                    for i=1:len_As
                        for j=1:len_Bs
                            this.connectionMat(As(i),Bs(j)) = .5;
                            %this.connectionMat(Bs(i),As(j)) = .5;
                            this.connectionDelayMat(As(i),Bs(j)) = 0;
                            %this.connectionDelayMat(Bs(i),As(j)) = 0;
                        end
                    end
                case 5
                    for i=1:len_As
                        for j=1:len_Bs
                            this.connectionMat(As(i),Bs(j)) = StrengthMat(As(i), Bs(j));
                            %this.connectionMat(Bs(j),As(i)) = StrengthMat(j, i);
                            this.connectionDelayMat(As(i),Bs(j)) = DelayMat(As(i),Bs(j));
                            %this.connectionDelayMat(Bs(i),As(j)) = DelayMat(Bs(i),As(j));
                        end
                    end
                otherwise
                    error('Wrong number of arguments');
            end
        end
        
        % TODO(Partha) : Add undirected connection functionality
        function this = addNode(this, node)
            num_elem = length(this.list_nodes);
            this.list_nodes{num_elem+1} = node;
            this.connectionMat(num_elem+1,1:num_elem) = zeros(1,num_elem);
            this.connectionMat(1:num_elem+1,num_elem+1) = zeros(num_elem+1,1);
        end
        % TODO(Dinesh) : Delete functionality may be needed
        function this = delete(this, node_index)
            % for i = 1:length(this.list_nodes)
                % if node.x_==this.list_nodes{i}.x_ && node.y_==this.list_nodes{i}.y_
                % use(ing) node index
                % instead/as well, overload function. Or as you need.
                % something like function this = delete(this, node_index)
                    this.list_nodes(node_index) = [];
                    this.connectionMat(node_index,:) =[];
                    this.connectionMat(:,node_index)=[];
                    this.connectionDelayMat(:,node_index) = [];
                    this.connectionDelayMat(node_index,:) = [];
                % end
            % end
        end
        
        function this = simulateNetwork(this, dt)
            % Time delay is between the nodes is assumed to be zero now
            % The 't_ij' parameter in the paper
            effectFromNeighbours = 0;
            for indexCurrentNode = 1:length(this.list_nodes)
                % This still performs directed graph structure. Can be made
                % more efficient if we assume no directivity
                for indexConnedtedNode = 1:length(this.list_nodes)
                    
                    effectFromNeighbours = effectFromNeighbours +...
                        this.connectionMat(indexCurrentNode, indexConnedtedNode)...
                        *this.list_nodes{indexCurrentNode}.health_(1 + this.connectionDelayMat(indexCurrentNode, indexConnedtedNode))...
                        *exp(-this.list_nodes{indexCurrentNode}.Settings_.beta...
                        *this.connectionDelayMat(indexCurrentNode, indexConnedtedNode))...
                        /this.connectivityWeight(indexConnedtedNode);
                end
                this.list_nodes{indexCurrentNode} = this.list_nodes{indexCurrentNode}.runNode(dt, effectFromNeighbours);
            end
        end
        function weight = connectivityWeight(this, indexConnedtedNode)
            % this.connectionMat
            O_j = find(this.connectionMat(indexConnedtedNode,:) > 0);
            weight = this.a*O_j/(1 + this.b * O_j);
        end
    end
end


