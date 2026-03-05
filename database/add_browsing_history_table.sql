CREATE TABLE browsing_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT '用户ID',
    product_id INT NOT NULL COMMENT '商品ID',
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
    INDEX idx_user_id (user_id),
    INDEX idx_viewed_at (viewed_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='浏览记录表';
