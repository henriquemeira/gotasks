import { request } from "./client";

export interface Task {
  id: number;
  title: string;
  description: string;
  done: boolean;
  created_at: string;
  updated_at: string;
}

export interface ListTasksParams {
  limit?: number;
  offset?: number;
}

export interface CreateTaskPayload {
  title: string;
  description?: string;
  done?: boolean;
}

export interface UpdateTaskPayload {
  title: string;
  description?: string;
  done?: boolean;
}

export interface PatchTaskPayload {
  title?: string;
  description?: string;
  done?: boolean;
}

export function listTasks(params: ListTasksParams = {}): Promise<Task[]> {
  const qs = new URLSearchParams();
  if (params.limit !== undefined) qs.set("limit", String(params.limit));
  if (params.offset !== undefined) qs.set("offset", String(params.offset));
  const query = qs.toString() ? `?${qs.toString()}` : "";
  return request<Task[]>(`/api/v1/tasks${query}`);
}

export function getTask(id: number): Promise<Task> {
  return request<Task>(`/api/v1/tasks/${id}`);
}

export function createTask(payload: CreateTaskPayload): Promise<Task> {
  return request<Task>("/api/v1/tasks", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateTask(id: number, payload: UpdateTaskPayload): Promise<Task> {
  return request<Task>(`/api/v1/tasks/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function patchTask(id: number, payload: PatchTaskPayload): Promise<Task> {
  return request<Task>(`/api/v1/tasks/${id}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}

export function deleteTask(id: number): Promise<void> {
  return request<void>(`/api/v1/tasks/${id}`, { method: "DELETE" });
}
