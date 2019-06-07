function [order_list] = get_order_list(dataset)
    level_matrix = get_level_matrix(dataset)
    N = numel(dataset);
    for i = 1:1:N
        [rank, index] = sort(level_matrix(i,:), 'descend');
        rank_matrix(i,:) = index;
    end
    rank_matrix
    order_list = [];
    base = mode(rank_matrix(:,1));
    order_list(1) = base;
    i = 2;
    j = base;
    while length(order_list) < N
        k = 1;
        while ismember(rank_matrix(j,k), order_list)
            k = k + 1;
        end
        order_list(i) = rank_matrix(j,k);
        j = order_list(i);
        i =  i + 1;
    end 
    
end

function [level_matrix] = get_level_matrix(dataset)
    N = numel(dataset);
    level_matrix = zeros(N, N);
    [feature_map, points_map] = get_feature_map(dataset);
    for i = 1:1:N
        for j = 1:1:N
            if i ~= j
                [level_matrix(i, j)] = kd_match(feature_map(i).cluster', feature_map(j).cluster');
            end
        end
    end           

end

function [match_points_num] = kd_match(descs1, descs2)
    n1 = size(descs1,2);
%     n2 = size(descs2,2);
    match = zeros(n1, 1);
    kdtree = KDTreeSearcher(descs2');
    for i = 1:size(descs1,2)
        desc = descs1(:, i);
        [idx D] = knnsearch(kdtree, desc', 'K', 2);
        nn_1 = descs2(:,idx(1));
        nn_2 = descs2(:,idx(2));
        if sum((desc - nn_1).^2)/sum((desc - nn_2).^2) < 0.6
            match(i) = idx(1);
        else
            match(i) = 0;
        end
%         match(i) = sum((desc - nn_1).^2)/sum((desc - nn_2).^2);
    end
    match_points_num = sum(sum(match));
end

function [feature_map, points_map] = get_feature_map(dataset)
    N = numel(dataset);
    for i = 1:1:N
        [feature, points] = get_features(dataset{i});
        feature_map(i)=struct('cluster',feature); 
        points_map(i)=struct('cluster',points); 
    end
end


