package com.healthmall.dto;

import java.util.List;

public class MerchantProductListResponse {
    private List<MerchantProductResponse> list;
    private Integer total;
    private Integer page;
    private Integer pageSize;
    private Integer totalPages;

    public List<MerchantProductResponse> getList() {
        return list;
    }

    public void setList(List<MerchantProductResponse> list) {
        this.list = list;
    }

    public Integer getTotal() {
        return total;
    }

    public void setTotal(Integer total) {
        this.total = total;
    }

    public Integer getPage() {
        return page;
    }

    public void setPage(Integer page) {
        this.page = page;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }
}
